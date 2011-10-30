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

  def name!
    return self.username.titleize
  end

  def has_trend
    self.measures.size > 6
  end

  def encrypt_password(pass)
    BCrypt::Engine.hash_secret(pass, password_salt)
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

  def last(days)
    m = Measure.where(:person_id=>self.id).order('measure_date desc')

    if m[0] and m[days-1] and  m[0].trend and m[days - 1].trend
      diff = m[days - 1].trend - m[0].trend 
      last = diff / (days / 7)
    else
      last = nil 
    end
    return 0 - last if last
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
      return karma_rank
    end
  end

  def leanbodymass
    weight - fat
  end

  def get_measures(num)
    Measure.where(:person_id => self.id).order('measure_date desc').limit(num)
  end

  def refresh
    wuser = Withings::User.info(self.withings_id, self.withings_api_key)
    wuser.share()
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

    return measures_count
  end

  private

  def prepare_password
    unless password.blank?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = encrypt_password(password)
    end
  end

end
