class AddBingeToMeasure < ActiveRecord::Migration
  def change 
    add_column :people, :binge_percentage, :integer, :default => 99
  end
end
