require 'withings'
include Withings

class Person < ActiveRecord::Base
  include Gravtastic

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  is_gravtastic

  attr_accessible :remember_me,:username, :email, :password, 
    :password_confirmation, :withings_id, :withings_api_key, 
    :height_feet, :height_inches, :goal,:goal_type,
    :private, :alpha, :binge_percentage, :measures_to_show, :time_to_send_email,
    :send_email

  has_many      :measures
  has_many      :posts
  validates_presence_of :username
  validates_uniqueness_of :username, :email, :allow_blank => true
  validates_format_of :username, :with => /^[-\w\._@]+$/i, :allow_blank => true, :message => "should only contain letters, numbers, or .-_@"
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
  validates_presence_of :password, :on => :create
  validates_confirmation_of :password
  validates_length_of :password, :minimum => 4, :allow_blank => true
  validates_numericality_of :goal, :greater_than => 0, :less_than => 450, :on => :update
  validates_numericality_of :height_feet, :greater_than => 3, :less_than => 8
  validates_numericality_of :height_inches, :greater_than_or_equal_to => 0, :less_than => 12
  validates_numericality_of :alpha, :greater_than_or_equal_to => 0.1, :less_than => 0.3
  validates_numericality_of :binge_percentage, :greater_than_or_equal_to => 90, :less_than => 110
  validates_numericality_of :measures_to_show, :only_integer => true, :on => :update

  def self.online
    return true
  end

  def name!
    return self.username.titleize
  end

  def has_trend
    self.measures.size > 6
  end

  def encrypt_password(pass)
    BCrypt::Engine.hash_secret(pass, password_salt)
  end

  def current_karma_grade
    karma_grade self.current_measure
  end

  def karma_grade(measure)
    if measure == nil
      return "NA"
    end

    case measure.karma
    when 90..100
      karma_grade = 'A'
      remainder = measure.karma - 90
    when 80..90
      karma_grade = 'B'
      remainder = measure.karma - 80
    when 70..80
      karma_grade = 'C'
      remainder = measure.karma - 70
    when 60..70
      karma_grade = 'D'
      remainder = measure.karma - 60
    else
      karma_grade = 'F'
      remainder = 5
    end

    case remainder
    when 7..10
      karma_grade += '+'
    when 0..4
      karma_grade += '-'
    end 

    return karma_grade
  end

  def get_bmi(weight)
    height = height_feet * 12 + height_inches
    return (weight * 703 / height**2)
  end

  #This method returns the average over some number of days
  def last(days)
    m = Measure.where(:person_id=>self.id).order('measure_date desc')

    if m[0] and m[days-1] and  m[0].trend and m[days - 1].trend
      diff = m[days - 1].trend - m[0].trend 
      last = diff / (days / 7)
    else
      last = nil 
    end
    if last
    return 0 - last
    else
     return 0
    end
  end

  def in3months
    @in3months = current_measure.item + (last(7) * 4 * 3) if last(7) and current_measure
  end

  def current_measure
    measures = Measure.where(:person_id => self.id).order('measure_date desc').limit(1)
    return measures[0]
  end

  def karma_rank
    karma_rank = 1
    measures = Measure.where(:person_id => self.id)

    measures.each do |measure|
      if measure.karma 
        if current_measure.karma
          if measure.karma > current_measure.karma
            karma_rank = karma_rank + 1 
          end
        end
      end
    end
    return karma_rank
  end

  def leanbodymass
    weight - fat
  end

  def get_measures(num)
    Measure.where(:person_id => self.id).order('measure_date desc').limit(num)
  end

  def wuser
    wuser = Withings::User.info(self.withings_id, self.withings_api_key)
  end
  
  def refresh_all
    page = 1
    per_page = 40
    has_more = true
    measures_count = 0

    wuser = self.wuser
    wuser.share()

    last_weight = self.current_measure
    puts last_weight.to_yaml

    while has_more
      measurements = wuser.measurement_groups(:per_page => per_page, 
                                              :page => page, 
                                              :start_at => last_weight==nil ? Time.at(0) : last_weight.measure_date + 1,
                                              :end_at => Time.now) 
      has_more = measurements.size == per_page
      measures_count = measures_count + measurements.size
      page = page + 1
      puts 'mc = ' + measures_count.to_s
      puts 'ms = ' + measurements.size.to_s

      measurements.each do |measurement|
        if measurement.weight and measurement.fat and measurement.taken_at
          measure = Measure.new
          measure.person_id = self.id
          measure.weight = measurement.weight * 2.20462262
          measure.fat = measurement.fat * 2.20462262
          measure.measure_date = measurement.taken_at
          measure.manual = false
          measure.save
        end
      end    
    end
    measures_count
  end

  def refresh_all_2
    wuser = self.wuser
    wuser.share()
    old_measures = self.measures
    self.measures.delete_all
    measures_count = 0
    last_measures_count = 0
    page = 1

    begin
      #measurements = wuser.measurement_groups(:per_page=>10, :page => page, :end_at=>Time.now)
      measurements = wuser.measurement_groups(:limit=>10, :offset=>last_measures_count, :end_at=>Time.now)

      measurements.each do |measurement|
        if measurement.weight and measurement.fat and measurement.taken_at
          measure = Measure.new
          measure.person_id = self.id
          measure.weight = measurement.weight * 2.20462262
          measure.fat = measurement.fat * 2.20462262
          measure.measure_date = measurement.taken_at
          measure.manual = false
          measure.save
          measures_count = measures_count + 1
        end
      end    
      page = page + 1
      last_measures_count = measurements.size
    end while measurements.size == 0 or page == 5

    #Idk why this can fail but if it does restore last set of valid measures
    #    if old_measures.size > self.measures.size
    #      self.measures = old_measures
    #      self.measures.save_all
    #    end

    return measures_count
  end

  def refresh
    wuser = self.wuser
    wuser.share()
    old_measures = self.measures
    self.measures.delete_all
    measures_count = 0

    measurements = wuser.measurement_groups(:per_page=>100)

    measurements.each do |measurement|
      if measurement.weight and measurement.fat and measurement.taken_at
        measure = Measure.new
        measure.person_id = self.id
        measure.weight = measurement.weight * 2.20462262
        measure.fat = measurement.fat * 2.20462262
        measure.measure_date = measurement.taken_at
        measure.save
            measures_count = measures_count + 1
      end
    end    

    #Idk why this can fail but if it does restore last set of valid measures
    if old_measures.size > self.measures.size
      self.measures = old_measures
      self.measures.save_all
    end

    return measures_count
  end

  def email_subject
    subject = 'Slim: ' + Utility.floatformat % self.current_measure.karma + ' '
    subject = subject + self.karma_grade(self.current_measure) + ' '
    subject = subject + 'Rank: ' + self.karma_rank.to_s + '/' + self.measures.size.to_s + ' '  
    subject = subject + 'Now ' + Utility.floatformat % self.current_measure.item.to_s + ' ' 
    subject = subject + 'Trend ' + Utility.floatformat % self.current_measure.trend.to_s + ' ' 
    subject = subject + Utility.floatstringlbs(self.last(7).to_s) + ', '
    subject = subject + Utility.floatformat % self.in3months + ' in 3 months'
    return subject
  end

  private

  def prepare_password
    unless password.blank?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = encrypt_password(password)
    end
  end

end
