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

  def is_binge?
    if ((measure.trend / measure.weight) * 100) < measure.person.binge_percentage
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
end
