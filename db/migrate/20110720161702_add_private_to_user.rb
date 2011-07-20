class AddPrivateToUser < ActiveRecord::Migration
  def self.up
    add_column :people, :private, :boolean
  end

  def self.down
  end
end
