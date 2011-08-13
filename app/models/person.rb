class Person < ActiveRecord::Base
  include Gravtastic
  is_gravtastic
  
  # new columns need to be added here to be writable through mass assignment
  #attr_accessible :username, :email, :password, :password_confirmation
  attr_accessible :username, :email, :password, :password_confirmation, :withings_id, :withings_api_key, :height_feet, :height_inches, :goal,:goal_type,:private, :alpha

  attr_accessor :password
  before_save :prepare_password

  has_many      :measures

  validates_presence_of :username
  validates_uniqueness_of :username, :email, :allow_blank => true
  validates_format_of :username, :with => /^[-\w\._@]+$/i, :allow_blank => true, :message => "should only contain letters, numbers, or .-_@"
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
  validates_presence_of :password, :on => :create
  validates_confirmation_of :password
  validates_length_of :password, :minimum => 4, :allow_blank => true
  validates_numericality_of :goal, :greater_than => 50, :less_than => 450
  validates_numericality_of :height_feet, :greater_than => 3, :less_than => 8
  validates_numericality_of :height_inches, :greater_than_or_equal_to => 0, :less_than => 12
  validates_numericality_of :alpha, :greater_than_or_equal_to => 0.1, :less_than => 0.3


  def self.authenticate(login, pass)
    person = find_by_username(login) || find_by_email(login)
    return person if person && person.password_hash == person.encrypt_password(pass)
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
      karma_rank = karma_rank + 1 if measure.karma and measure.karma > current_measure.karma
    end
    return karma_rank
  end

  def leanbodymass
    weight - fat
  end

  def get_measures(num)
    Measure.where(:person_id => self.id).order('measure_date desc').limit(num)
  end

  private

  def prepare_password
    unless password.blank?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = encrypt_password(password)
    end
  end

end
