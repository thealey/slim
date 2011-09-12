class AddKarmaToMeasure < ActiveRecord::Migration
  def change 
    add_column :measures, :karma, :float
  end
end
