class AddTrendFieldsToMeasures < ActiveRecord::Migration
  def self.up
    add_column  :measures, :forecast, :float
    add_column  :measures, :delta, :float
  end

  def self.down
    remove_column  :measures, :forecast
    remove_column  :measures, :delta
  end
end
