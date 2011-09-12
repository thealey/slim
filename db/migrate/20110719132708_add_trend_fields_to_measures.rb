class AddTrendFieldsToMeasures < ActiveRecord::Migration
  def change 
    add_column  :measures, :forecast, :float
    add_column  :measures, :delta, :float
  end
end
