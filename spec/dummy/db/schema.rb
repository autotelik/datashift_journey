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

ActiveRecord::Schema.define(version: 20160907091700) do

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

  create_table "checkout_as", force: :cascade do |t|
    t.string   "checkout_a"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "checkout_bs", force: :cascade do |t|
    t.string   "checkout_b"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "checkout_cs", force: :cascade do |t|
    t.string   "checkout_c"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "checkout_ds", force: :cascade do |t|
    t.string   "checkout_d"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "checkout_empties", force: :cascade do |t|
    t.string   "checkout_empty"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "checkout_es", force: :cascade do |t|
    t.string   "checkout_e"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "checkout_fs", force: :cascade do |t|
    t.string   "checkout_f"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "checkouts", force: :cascade do |t|
    t.string   "state"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "token"
    t.integer  "bill_address_id"
    t.integer  "ship_address_id"
    t.integer  "payment_id"
  end

  add_index "checkouts", ["bill_address_id"], name: "index_checkouts_on_bill_address_id"
  add_index "checkouts", ["payment_id"], name: "index_checkouts_on_payment_id"
  add_index "checkouts", ["ship_address_id"], name: "index_checkouts_on_ship_address_id"
  add_index "checkouts", ["token"], name: "index_checkouts_on_token", unique: true

  create_table "datashift_journey_collectors", force: :cascade do |t|
    t.string   "state"
    t.string   "reference"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "datashift_journey_collectors", ["reference"], name: "index_datashift_journey_collectors_on_reference"
  add_index "datashift_journey_collectors", ["state"], name: "index_datashift_journey_collectors_on_state"

  create_table "datashift_journey_collectors_data_nodes", force: :cascade do |t|
    t.integer "collector_id", null: false
    t.integer "data_node_id", null: false
    t.integer "position"
  end

  add_index "datashift_journey_collectors_data_nodes", ["collector_id", "data_node_id"], name: "collectors_data_nodes_collector_id_data_node_id", unique: true

  create_table "datashift_journey_data_nodes", force: :cascade do |t|
    t.string   "form_name"
    t.string   "field"
    t.string   "field_presentation", limit: 100
    t.string   "field_type"
    t.text     "field_value"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "datashift_journey_data_nodes", ["field"], name: "index_datashift_journey_data_nodes_on_field"
  add_index "datashift_journey_data_nodes", ["form_name"], name: "index_datashift_journey_data_nodes_on_form_name"

  create_table "payments", force: :cascade do |t|
    t.string   "name"
    t.string   "card"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
