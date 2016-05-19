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
    t.string   "premises",       limit: 200
    t.string   "street_address", limit: 160
    t.string   "locality",       limit: 70
    t.string   "city",           limit: 30
    t.string   "postcode",       limit: 8
    t.string   "country_iso",    limit: 3
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "checkouts", force: :cascade do |t|
    t.string   "state"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "bill_address_id"
    t.integer  "ship_address_id"
    t.integer  "payments_id"
  end

  add_index "checkouts", ["bill_address_id"], name: "index_checkouts_on_bill_address_id"
  add_index "checkouts", ["payments_id"], name: "index_checkouts_on_payments_id"
  add_index "checkouts", ["ship_address_id"], name: "index_checkouts_on_ship_address_id"

  create_table "payments", force: :cascade do |t|
    t.string   "name"
    t.string   "card"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
