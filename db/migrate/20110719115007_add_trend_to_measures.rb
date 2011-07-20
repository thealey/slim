class AddTrendToMeasures < ActiveRecord::Migration
  def self.up
	add_column :measures, :trend, :float
  end

  def self.down
  end
end
