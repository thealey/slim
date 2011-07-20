class Measure < ActiveRecord::Base
  attr_accessible :weight, :person_id, :measure_date, :fat
  
  belongs_to :person
  validates_presence_of :weight
  validates_presence_of :person_id
  validates_presence_of :measure_date
end
