class DeviseCreatePeople < ActiveRecord::Migration
  def self.up
    change_table(:people) do |t|
      #t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable

      add_column :people, :encrypted_password, :string
      #add_column :people, :password_salt, :string

      # t.encryptable
      # t.confirmable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable
    end

    #add_index :people, :email,                :unique => true
    add_index :people, :reset_password_token, :unique => true
    # add_index :people, :confirmation_token,   :unique => true
    # add_index :people, :unlock_token,         :unique => true
    # add_index :people, :authentication_token, :unique => true
  end

  def self.down
    drop_table :people
  end
end
