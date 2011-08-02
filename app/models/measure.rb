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

  def fatpercentage
    fat / weight * 100
  end     
end
