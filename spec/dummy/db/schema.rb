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

ActiveRecord::Schema.define(version: 20160211112943) do

  create_table "dsc_address_contacts", id: false, force: :cascade do |t|
    t.integer "address_id", null: false
    t.integer "contact_id", null: false
  end

  add_index "dsc_address_contacts", ["address_id"], name: "index_dsc_address_contacts_on_address_id"
  add_index "dsc_address_contacts", ["contact_id"], name: "index_dsc_address_contacts_on_contact_id"

  create_table "dsc_address_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dsc_addresses", force: :cascade do |t|
    t.string   "premises",            limit: 200
    t.string   "street_address",      limit: 160
    t.string   "locality",            limit: 70
    t.string   "city",                limit: 30
    t.string   "postcode",            limit: 8
    t.integer  "county_province_id"
    t.string   "country_iso",         limit: 3
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "address_type",                    default: 0,  null: false
    t.string   "organisation",        limit: 255, default: "", null: false
    t.date     "state_date"
    t.string   "blpu_state_code"
    t.string   "postal_address_code"
    t.string   "logical_status_code"
  end

  create_table "dsc_contacts", force: :cascade do |t|
    t.integer  "contact_type",                   default: 0, null: false
    t.integer  "title",                          default: 0, null: false
    t.string   "suffix",             limit: 255
    t.string   "first_name",         limit: 255
    t.string   "last_name",          limit: 255
    t.date     "date_of_birth"
    t.string   "position",           limit: 255
    t.string   "email_address",      limit: 255
    t.date     "valid_from"
    t.date     "valid_to"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "primary_address_id"
  end

  add_index "dsc_contacts", ["primary_address_id"], name: "index_dsc_contacts_on_primary_address_id"

  create_table "dsc_county_provinces", force: :cascade do |t|
    t.string   "name"
    t.string   "abbr"
    t.string   "country_iso", limit: 3
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "dsc_journey_plans", force: :cascade do |t|
    t.string   "state"
    t.boolean  "under_review",              default: false
    t.datetime "submitted_at"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "parties_id"
    t.integer  "applicant_contact_id"
    t.integer  "correspondence_contact_id"
    t.string   "token"
    t.integer  "status",                    default: 0,     null: false
  end

  add_index "dsc_journey_plans", ["applicant_contact_id"], name: "index_dsc_journey_plans_on_applicant_contact_id"
  add_index "dsc_journey_plans", ["correspondence_contact_id"], name: "index_dsc_journey_plans_on_correspondence_contact_id"
  add_index "dsc_journey_plans", ["parties_id"], name: "index_dsc_journey_plans_on_parties_id"
  add_index "dsc_journey_plans", ["state"], name: "index_dsc_journey_plans_on_state"
  add_index "dsc_journey_plans", ["submitted_at"], name: "index_dsc_journey_plans_on_submitted_at"

  create_table "dsc_locations", force: :cascade do |t|
    t.integer  "address_id"
    t.string   "grid_reference"
    t.string   "uprn"
    t.string   "lat"
    t.string   "long"
    t.string   "x"
    t.string   "y"
    t.date     "valid_from"
    t.date     "valid_to"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "coordinate_system"
  end

  create_table "dsc_organisations", force: :cascade do |t|
    t.string   "type"
    t.string   "name",           limit: 255
    t.integer  "contact_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "company_number", limit: 255
  end

  create_table "dsc_parties", force: :cascade do |t|
    t.string   "type"
    t.string   "description"
    t.date     "valid_from"
    t.date     "valid_to"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "dsc_phone_numbers", force: :cascade do |t|
    t.integer  "number_type",             default: 0, null: false
    t.string   "tel_number",  limit: 255
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "contact_id"
  end

  add_index "dsc_phone_numbers", ["contact_id"], name: "index_dsc_phone_numbers_on_contact_id"

  create_table "dsc_versions", force: :cascade do |t|
    t.string   "item_type",                     null: false
    t.integer  "item_id",                       null: false
    t.string   "event",                         null: false
    t.string   "whodunnit"
    t.text     "object",     limit: 1073741823
    t.datetime "created_at"
  end

  add_index "dsc_versions", ["item_type", "item_id"], name: "index_dsc_versions_on_item_type_and_item_id"

end
