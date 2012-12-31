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
    :send_email, :workout_goal

  has_many      :measures
  has_many      :posts
  has_many      :workouts

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

  def first_workout_date
    if self.workouts.size > 0
      Workout.where(:person_id => self.id).order('workout_date asc').first.workout_date.to_date
    end
  end

  def first_record_date
    frd = Time.now.to_date
    first_measure = Measure.where(:person_id => self.id).order('measure_date asc').first

    if first_workout_date and first_workout_date < frd
      frd = first_workout_date
    end

    if first_measure and first_measure.measure_date < frd
      frd = first_measure.measure_date.to_date
    end
    frd
  end

  def get_current_measure(record_day)
    measures = self.measures.select{|m| m.measure_date.to_date == record_day}
    if measures.size == 0
      current_measure = Measure.new :measure_date => record_day,
        :person_id => self.id
    else
      #TODO: No double sessions!
      current_measure = measures.first
    end
    current_measure
  end

  def get_current_workout(workout_day)
    workouts = self.workouts.select{|w| w.workout_date.to_date == workout_day}
    if workouts.size == 0
      current_workout = Workout.new
      current_workout.workout_date = workout_day
      current_workout.person_id = self.id
      current_workout.rating = 0
    else
      #TODO: No double sessions!
      current_workout = workouts.first
    end
    current_workout
  end

  #Make sure they are padded for days with no workouts
  def grade_workout_range(workouts)
    workout_range = get_workout_range(workouts)
    workout_goal = self.workout_goal || 300
    current_score = workout_range.map { |workout| workout.rating }.sum
    workout_grade = ((current_score.to_f / workout_goal.to_f) * 100).to_i
    workout_grade = 100 if workout_grade > 100

    {
      :current_score => current_score,
      :workout_grade => workout_grade
    }
  end

  def get_workout_range(workouts)
    if workouts.size > 7
      workout_range = workouts[workouts.size - 7,
        workouts.size]
    else
      workout_range = Array.new
    end
    workout_range
  end

  def all_workout_days(workout_day = self.first_record_date)
    workout_days = Array.new
    score = Hash.new
    against_goal = Hash.new

    while workout_day <= Time.now.to_date do
      current_workout = get_current_workout(workout_day)
      workout_days << current_workout

      gwr = grade_workout_range(workout_days)
      against_goal[workout_day] = gwr[:current_score]
      score[workout_day] = gwr[:workout_grade]
      workout_day = workout_day + 1.day
    end

    {
      :workouts => workout_days.reverse!.flatten,
      :scores => score,
      :against_goal => against_goal
    }
  end

  def get_measures_hash
    mh = Hash.new

    self.measures.each do |m|
      mh[m.measure_date.to_date] = m
    end
    mh
  end

  def all_measure_days
    loop_measure_day = self.first_record_date
    weight_days = Hash.new
    karma_days = Hash.new
    trend_days = Hash.new
    measures_hash = get_measures_hash
    last_real_measure = nil

    while loop_measure_day <= Time.now.to_date do
      current_measure = measures_hash[loop_measure_day.to_date]
      if current_measure.nil?
        current_measure = Measure.new :measure_date => loop_measure_day,
          :person_id => self.id, :karma => last_real_measure.karma
        weight_days[loop_measure_day] = last_real_measure.weight
        karma_days[loop_measure_day] = last_real_measure.karma
        trend_days[loop_measure_day] = last_real_measure.trend
      else
        last_real_measure = current_measure
      end

      if current_measure.weight
        weight_days[loop_measure_day] = current_measure.weight
        karma_days[loop_measure_day] = current_measure.karma
        trend_days[loop_measure_day] = current_measure.karma
      end
      loop_measure_day = loop_measure_day + 1.day
    end

    {
      :measures_hash => measures_hash,
      :weight => weight_days,
      :karma => karma_days
    }
  end

  def self.online
    return true
  end

  def name
    self.username
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

  def self.grade(grade_number)
    case grade_number
    when 100..1000
      karma_grade = 'A+'
      remainder = 5
    when 90..100
      karma_grade = 'A'
      remainder = grade_number - 90
    when 80..90
      karma_grade = 'B'
      remainder = grade_number - 80
    when 70..80
      karma_grade = 'C'
      remainder = grade_number - 70
    when 60..70
      karma_grade = 'D'
      remainder = grade_number - 60
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
    karma_grade
  end

  def karma_grade(measure)
    if measure == nil
      return "NA"
    end

    return Person.grade(measure.karma)
  end

  def get_bmi(weight)
    height = height_feet * 12 + height_inches
    return (weight * 703 / height**2)
  end

  #This method returns the trend over some number of days
  def trend_range(m)
    days = m.size
    return 0 if days < 7 

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

  def last(d)
    m = measure_range(Time.now - d.days, Time.now)
    return trend_range(m)
  end

  def measure_range(start_date, end_date)
    Measure.where('person_id = ? and measure_date >= ? and measure_date <= ?',
                  self.id, start_date.to_s(:db), end_date.to_s(:db)).order('measure_date desc')
  end

  def in3months
    three_month_trend current_measure
  end

  def three_month_trend(measure)
    ms = self.measure_range(measure.measure_date, measure.measure_date - 10.days)
    tr = trend_range(ms)
    measure.item + (tr * 4 * 3) if tr and measure
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

  def progress_report
    reports = Hash.new
    charts = Hash.new
    self.measures.order('measure_date desc').limit(30).each do |measure|
      body = ''
      body = body + self.username + ' weighed in on ' + measure.measure_date.to_date.to_s(:long) + ','
      body = body + ' at ' + measure.weight.to_s + '.'
      body = body + ' This is ' + Utility.floatformat % (measure.weight - measure.trend).to_s
      if measure.weight > measure.trend
        body = body + ' more '
      else 
        body = body + ' less '
      end
      body = body + 'than ' + self.username + '\'s' 
      body = body + ' trend weight of ' + measure.trend.to_s + '.'
      body = body + ' This represents a karma score of ' + measure.karma.to_s + ', which is a grade of '
      body = body + self.karma_grade(measure) + '.'
      #charts[measure.measure_date] = Measure.getchart(self.get_measures(7), '600x400')

      ms = self.measure_range(measure.measure_date - 14.days, measure.measure_date)
      body = body + ' 14 day trend is ' + self.trend_range(ms).round(3).to_s + '.'

      #measure.item + (tr * 4 * 3) if tr and measure
      body = body + ' At this rate in 3 months Ted will weigh ' + (measure.weight + self.trend_range(ms) * 4 * 3).round(2).to_s
      body = body + '.'
      reports[measure.measure_date] = body
    end
    reports
  end

  def stats(start_from)
    ms = Measure.where('measure_date <= ? and person_id = ?', start_from.to_s(:db), self.id)

    grades = [ 'A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D+', 'D', 'D-', 'F' ]
    grade = self.karma_grade(self.current_measure)

    ms.each do |m|

    end
  end

  private

  def prepare_password
    unless password.blank?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = encrypt_password(password)
    end
  end

end
