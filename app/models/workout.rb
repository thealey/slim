class Workout < ActiveRecord::Base
  attr_accessible :description, :rating, :workout_date
  belongs_to :person
  validates_presence_of :person_id, :workout_date

  def self.user_grades(person_id)
    workouts = Workout.where(:person_id => person_id).order('workout_date desc')
    return grades(workouts)
  end

  def self.grade_range(workout_range)
  end

  def self.grades(workouts)
    return workouts
  end
end
