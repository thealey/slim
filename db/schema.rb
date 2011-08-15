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

ActiveRecord::Schema.define(:version => 20110815113310) do

  create_table "measures", :force => true do |t|
    t.integer  "person_id"
    t.float    "weight"
    t.float    "fat"
    t.datetime "measure_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "trend"
    t.float    "forecast"
    t.float    "delta"
    t.float    "karma"
  end

  create_table "people", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "withings_id"
    t.string   "withings_api_key"
    t.integer  "height_feet"
    t.integer  "height_inches"
    t.integer  "goal"
    t.boolean  "private"
    t.float    "alpha",            :default => 0.1
    t.string   "goal_type",        :default => "lbs"
    t.integer  "binge_percentage", :default => 99
  end

  create_table "posts", :force => true do |t|
    t.string   "name"
    t.text     "body"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
