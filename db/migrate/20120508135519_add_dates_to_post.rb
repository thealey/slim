class AddDatesToPost < ActiveRecord::Migration
  def change
    add_column :posts, :start_date, :date

    add_column :posts, :end_date, :date

  end
end
