class Workout < ActiveRecord::Base
  attr_accessible :description, :rating, :workout_date
  belongs_to :person
  validates_presence_of :person_id, :workout_date
end
