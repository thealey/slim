class ChangeWeightToDecimal < ActiveRecord::Migration
  def change 
    change_column :measures, :weight, :float
    change_column :measures, :fat, :float
  end
end
