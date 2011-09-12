class AddMeasureNumberPrefToPerson < ActiveRecord::Migration
  def change 
    add_column :people, :measures_to_show, :integer
  end
end
