# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111110171610) do

  create_table "consumer_tokens", :force => true do |t|
    t.integer  "user_id"
    t.string   "type",       :limit => 30
    t.string   "token",      :limit => 1024
    t.string   "secret"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "measures", :force => true do |t|
    t.integer  "person_id"
    t.float    "weight"
    t.float    "fat"
    t.datetime "measure_date"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.float    "trend"
    t.float    "forecast"
    t.float    "delta"
    t.float    "karma"
    t.boolean  "manual",       :default => true
  end

  create_table "people", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "withings_id"
    t.string   "withings_api_key"
    t.integer  "height_feet"
    t.integer  "height_inches"
    t.integer  "goal"
    t.boolean  "private"
    t.float    "alpha",                  :default => 0.1
    t.string   "goal_type",              :default => "lbs"
    t.integer  "binge_percentage",       :default => 99
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "encrypted_password"
    t.integer  "measures_to_show"
    t.time     "time_to_send_email"
    t.boolean  "send_email"
  end

  add_index "people", ["reset_password_token"], :name => "index_people_on_reset_password_token", :unique => true

  create_table "posts", :force => true do |t|
    t.string   "name"
    t.text     "body"
    t.integer  "person_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
