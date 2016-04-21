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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160421220000) do

  create_table "addresses", force: :cascade do |t|
    t.string   "premises",        limit: 200
    t.string   "street_address",  limit: 160
    t.string   "locality",        limit: 70
    t.string   "city",            limit: 30
    t.string   "postcode",        limit: 8
    t.string   "country_iso",     limit: 3
    t.integer  "address_type",                default: 0, null: false
    t.integer  "registration_id"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  create_table "registrations", force: :cascade do |t|
    t.string   "name"
    t.boolean  "a_boolean"
    t.string   "some_string1"
    t.text     "some_text"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "state"
    t.boolean  "under_review", default: false
    t.datetime "submitted_at"
    t.datetime "completed_at"
    t.string   "token"
  end

  add_index "registrations", ["completed_at"], name: "index_registrations_on_completed_at"
  add_index "registrations", ["state"], name: "index_registrations_on_state"

end
