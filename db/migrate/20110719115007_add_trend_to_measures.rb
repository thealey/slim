class AddTrendToMeasures < ActiveRecord::Migration
  def change 
    add_column :measures, :trend, :float
  end
end
