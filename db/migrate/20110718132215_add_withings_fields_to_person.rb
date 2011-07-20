class AddWithingsFieldsToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :withings_id, :string
    add_column :people, :withings_api_key, :string
    add_column :people, :height_feet, :integer
    add_column :people, :height_inches, :integer
    add_column :people, :goal_weight, :integer
  end

  def self.down
  end
end
