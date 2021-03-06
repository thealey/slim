class CreateOauthConsumerTokens < ActiveRecord::Migration
  def change 
    create_table :consumer_tokens do |t|
      t.integer :user_id
      t.string :type, :limit => 30
      t.string :token, :limit => 1024 # This has to be huge because of Yahoo's excessively large tokens
      t.string :secret
      t.timestamps
    end
    execute 'alter table consumer_tokens charset=utf8;'
    #add_index :consumer_tokens, :token, :unique => true
  end
end
