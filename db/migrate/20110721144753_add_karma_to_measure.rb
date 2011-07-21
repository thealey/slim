class AddKarmaToMeasure < ActiveRecord::Migration
  def self.up
    add_column :measures, :karma, :float
  end

  def self.down
  end
end
