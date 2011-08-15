class AddBingeToMeasure < ActiveRecord::Migration
  def self.up
    add_column :people, :binge_percentage, :integer, :default => 99
  end

  def self.down
  end
end
