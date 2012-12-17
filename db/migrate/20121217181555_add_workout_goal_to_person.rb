class AddWorkoutGoalToPerson < ActiveRecord::Migration
  def change
    add_column :people, :workout_goal, :integer
  end
end
