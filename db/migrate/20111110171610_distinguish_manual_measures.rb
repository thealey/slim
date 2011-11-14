class DistinguishManualMeasures < ActiveRecord::Migration
  def up
    add_column    :measures, :manual, :boolean, :default=>true
  end

  def down
    remove_column    :measures, :manual
  end
end
