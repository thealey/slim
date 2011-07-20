class ChangeWeightToDecimal < ActiveRecord::Migration
  def self.up
    change_column :measures, :weight, :float
    change_column :measures, :fat, :float
  end

  def self.down
  end
end
