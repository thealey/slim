class Measure < ActiveRecord::Base
  attr_accessible :weight, :person_id, :measure_date, :fat

  belongs_to :person
  validates_presence_of :weight
  validates_presence_of :person_id
  validates_presence_of :measure_date

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
            measure.karma = 100 if measure.karma > 100
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
end
