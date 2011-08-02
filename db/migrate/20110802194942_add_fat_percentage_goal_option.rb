class AddFatPercentageGoalOption < ActiveRecord::Migration
  def self.up
    add_column :people, :goal_type, :string, :default=>"lbs"
    rename_column :people, :goal_weight, :goal
  end

  def self.down
  end
end
