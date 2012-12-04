class AddPersonIdToWorkouts < ActiveRecord::Migration
  def change
    add_column :workouts, :person_id, :integer
  end
end
