class Person < ActiveRecord::Base
  #include Gravtastic
  #is_gravtastic
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

  # login can be either username or email address
  def self.authenticate(login, pass)
    person = find_by_username(login) || find_by_email(login)
    return person if person && person.password_hash == person.encrypt_password(pass)
  end

  def gravatar_url
    return 'http://actualdownload.com/pictures/icon/software-icons---professional-xp-icons-for-software-and-web-12649.gif'
  end

  def latest_measure
    m = Measure.where(:person_id => id).order("measure_date desc").limit(1)
    return m[0] if m
  end
  
  def encrypt_password(pass)
    BCrypt::Engine.hash_secret(pass, password_salt)
  end

  def get_bmi(weight)
    height = height_feet * 12 + height_inches
    return (weight * 703 / height**2)
  end

  def last(days)
    if measures[0] and measures[days - 1]
      diff = measures[0].trend - measures[days - 1].trend
      last = diff / (days / 7)
    else
      last = nil 
    end
    return last
  end

  def in3months
    @in3months = measures[0].item + (last(7) * 4 * 3) if last(7) and measures[0]
  end

  def karma_rank
    kcount = 1
    karma_rank = 0
    karmas = Measure.where(:person_id => self.id).order('karma desc')
    karmas.each do |karma|
      if measures[0].measure_date == karma.measure_date
        karma_rank = kcount
      end
      kcount = kcount + 1
    end
    return karma_rank
  end

  def leanbodymass
    weight - fat
  end

  private

  def prepare_password
    unless password.blank?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = encrypt_password(password)
    end
  end

end
