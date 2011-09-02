class AddMeasureNumberPrefToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :measures_to_show, :integer
  end

  def self.down
  end
end
