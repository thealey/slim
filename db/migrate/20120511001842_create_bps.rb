class CreateBps < ActiveRecord::Migration
  def change
    create_table :bps do |t|
      t.integer :dia
      t.integer :person_id
      t.integer :sys
      t.date :measure_date

      t.timestamps
    end
  end
end
