class AddAlphaToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :alpha, :float, :default=>0.1
  end

  def self.down
    remove_column :people, :alpha
  end
end
