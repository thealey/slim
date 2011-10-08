class AddEmailPrefToPerson < ActiveRecord::Migration
  def change
    add_column :people, :time_to_send_email, :time
    add_column :people, :send_email, :boolean
  end
end
