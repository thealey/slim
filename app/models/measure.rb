require 'csv'

class Measure < ActiveRecord::Base
  attr_accessible :weight, :person_id, :measure_date, :fat, :karma

  belongs_to :person
  validates_presence_of :weight
  validates_presence_of :person_id
  validates_presence_of :measure_date

  def display
    if self.weight.nil?
      return '-'
    else
      return self.weight.to_i.to_s
    end
  end

  def item
    if person.goal_type == "lbs"
      return weight
    end
    if person.goal_type == "%fat"
      return fatpercentage
    end
    return nil
  end
  
  def trend_percentage
    unless self.trend and self.weight
      Measure.update_trend
      return 0
    else
      return ((self.trend / self.weight) * 100)
    end
  end

  def is_binge?
    if trend_percentage < self.person.binge_percentage
      return true
    else
      return false
    end
  end 

  def fatpercentage
    if fat and weight
      fat / weight * 100 
    else 
      return 0
    end
  end     

  def self.update_trend
    ActiveRecord::Base.connection.execute('update measures set trend = null, karma=null, trend = null, delta=null;')
    Person.all.each do |person|
      @measures = Measure.where(:person_id=>person.id).order('measure_date asc')
      counter = 0
      trend_days = 6
      alpha = person.alpha
      weightmult = 2
      trendmult = 10

      trend = 0
      delta = 0
      karma = 0
      previous_trend = 0

      #Need a week to get going
      if @measures.size > 6
        @measures.each do |measure|
          #I guess can't have a measure for the first day?
          #Yeah have to make a trend of the 7 just by averaging
          #Then from there can make a trend
          if counter == 0
            forecast = 0
            @measures[0..6].each do |m|
              forecast = forecast +  m.item
            end
            forecast = forecast / 7
            measure.forecast = forecast
          else
            #Ok so 1st measure has no forecast, subsequent ones will
            forecast = @measures[counter - 1].trend
          end

          trend = (alpha * measure.item) + (1 - alpha) * forecast
          trenddiff = (trend - previous_trend)
          diff = measure.item - person.goal
          unless counter == 0
            measure.karma = 100 - (diff * weightmult) - (trenddiff * trendmult)
            #measure.karma = 100 if measure.karma > 100
          end

          measure.trend = trend
          previous_trend = trend

          delta = measure.item - forecast
          measure.forecast = forecast
          measure.delta = delta
          measure.save
          counter = counter + 1
        end
      end
    end
  end

  def self.getchart(measures, chartsize)
    person = measures.first.person
    max_days = person.measures.size
    trends = Array.new
    weights = Array.new
    fats = Array.new
    goals = Array.new
    karmas = Array.new
    daylimit = measures.size
    title = measures.size.to_s + ' Measure Trend ' + Utility.floatstringlbs(person.trend_range(measures).to_s)
    max = 0
    min = 1000
    lcurl = ''

    measures.each do |measure|
      return '' if measure.trend.nil?
      trends << measure.trend
      fats << measure.fatpercentage
      weights << measure.weight
      karmas << measure.karma - 10 if measure.karma

      min = measure.item if measure.item < min
      max = measure.item if measure.item > max

      min = measure.trend if measure.trend < min
      max = measure.trend if measure.trend > max
      goals << person.goal
    end
    #max = max + 1

    min = person.goal - person.goal * 0.02 if daylimit == max_days

    scaled_trends = scale_array(trends, min, max)
    scaled_weights = scale_array(weights, min, max)
    scaled_fats = scale_array(fats, min, max)
    scaled_karmas = scale_array(karmas, 0, 100)
    #scaled_karmas.reverse!
    scaled_goals = scale_array(goals, min, max)

    GoogleChart::LineChart.new(chartsize, title, false) do |lc|
      lc.show_legend = true
      lc.data "Trend", scaled_trends, 'D80000'
      if person.goal_type == 'lbs'
        lc.data "Weight", scaled_weights, 'BDBDBD'
      end
      if person.goal_type == '%fat'
        #lc.data "%Fat", scaled_fats, 'BDBDBD'
      end
      lc.data "Goal", scaled_goals, '254117'
      lc.fill(:background, :solid, {:color => 'ffffff'})
      #lc.data "Karma", scaled_karmas, 'B8B8B8'
      lc.axis :y, :range => [min, max], :color => '667B99', :font_size => 10, :alignment => :center
      lc.axis :x, :range => [daylimit,1], :color => '667B99', :font_size => 10, :alignment => :center
      lc.grid :x_step => 5, :y_step => 5, :length_segment => 1, :length_blank => 0
      lcurl = lc.to_url(:chds=>'a')
    end
    return lcurl
  end

  def self.scale_array(myarray, min, max)
    scaled_array = Array.new
    old_range = (max - min)
    myarray.reverse!

    myarray.each do |item|
      scaled_array << (((item - min) * 100) / old_range)
    end
    return scaled_array
  end  

  def self.import_test
    Measure.import(File.read("./misc/imports.csv"), 1)
  end

  def self.eval_date(s)
    return Chronic::parse(s).to_date
  end

  def self.eval_float(s)
    begin
      return Float(s)
    rescue ArgumentError
    end
  end

  def self.import(csv, person_id)
    return unless p = Person.find(person_id)

    rows = CSV.parse(csv)
    p.measures.delete_all

    rows.each do |row|
      m = Measure.new

      if eval_float(row[0])
        m.weight = eval_float(row[0])
      else
        m.measure_date = eval_date(row[0]) if eval_date(row[0])
      end
      if eval_float(row[1])
        m.weight = eval_float(row[1])
      else
        m.measure_date = eval_date(row[1]) if eval_date(row[1])
      end

      if m.weight and m.measure_date
        m.person_id = p.id
        m.save!
      end
    end
  end
end
