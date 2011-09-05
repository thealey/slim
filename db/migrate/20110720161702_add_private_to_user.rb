class AddPrivateToUser < ActiveRecord::Migration
  def change 
    add_column :people, :private, :boolean
  end
end
