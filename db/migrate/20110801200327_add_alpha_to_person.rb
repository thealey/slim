class AddAlphaToPerson < ActiveRecord::Migration
  def change 
    add_column :people, :alpha, :float, :default=>0.1
  end
end
