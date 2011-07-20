class CreateMeasures < ActiveRecord::Migration
  def self.up
    create_table :measures do |t|
      t.integer :person_id
      t.integer :weight
      t.integer :fat
      t.datetime :measure_date
      t.timestamps
    end
  end

  def self.down
    drop_table :measures
  end
end
