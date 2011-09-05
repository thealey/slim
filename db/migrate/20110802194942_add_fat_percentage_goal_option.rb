class AddFatPercentageGoalOption < ActiveRecord::Migration
  def change 
    add_column :people, :goal_type, :string, :default=>"lbs"
    rename_column :people, :goal_weight, :goal
  end
end
