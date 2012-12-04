class CreateWorkouts < ActiveRecord::Migration
  def change
    create_table :workouts do |t|
      t.integer :rating
      t.string :description

      t.timestamps
    end
  end
end
