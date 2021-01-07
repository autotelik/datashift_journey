# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2016_12_21_100703) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string "premises", limit: 200
    t.string "street_address", limit: 160
    t.string "locality", limit: 70
    t.string "city", limit: 30
    t.string "postcode", limit: 8
    t.string "country_iso", limit: 3
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "datashift_journey_checkout_as", force: :cascade do |t|
    t.string "checkout_a"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "datashift_journey_checkout_bs", force: :cascade do |t|
    t.string "checkout_b"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "datashift_journey_checkout_cs", force: :cascade do |t|
    t.string "checkout_c"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "datashift_journey_checkout_ds", force: :cascade do |t|
    t.string "checkout_d"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "datashift_journey_checkout_empties", force: :cascade do |t|
    t.string "checkout_empty"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "datashift_journey_checkout_es", force: :cascade do |t|
    t.string "checkout_e"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "datashift_journey_checkout_fs", force: :cascade do |t|
    t.string "checkout_f"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "datashift_journey_checkouts", force: :cascade do |t|
    t.string "state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "token"
    t.bigint "bill_address_id"
    t.bigint "ship_address_id"
    t.bigint "payment_id"
    t.index ["bill_address_id"], name: "index_datashift_journey_checkouts_on_bill_address_id"
    t.index ["payment_id"], name: "index_datashift_journey_checkouts_on_payment_id"
    t.index ["ship_address_id"], name: "index_datashift_journey_checkouts_on_ship_address_id"
  end

  create_table "datashift_journey_payments", force: :cascade do |t|
    t.string "name"
    t.string "card"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "dsj_data_nodes", force: :cascade do |t|
    t.string "plan_type", null: false
    t.bigint "plan_id", null: false
    t.bigint "form_field_id", null: false
    t.text "field_value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["form_field_id"], name: "index_dsj_data_nodes_on_form_field_id"
    t.index ["plan_type", "plan_id"], name: "index_dsj_data_nodes_on_plan"
  end

  create_table "dsj_fields_snippets", force: :cascade do |t|
    t.bigint "form_field_id", null: false
    t.bigint "snippet_id", null: false
    t.index ["form_field_id"], name: "index_dsj_fields_snippets_on_form_field_id"
    t.index ["snippet_id"], name: "index_dsj_fields_snippets_on_snippet_id"
  end

  create_table "dsj_form_definitions", force: :cascade do |t|
    t.string "state", null: false
    t.string "klass", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["klass"], name: "index_dsj_form_definitions_on_klass"
    t.index ["state"], name: "index_dsj_form_definitions_on_state"
  end

  create_table "dsj_form_fields", force: :cascade do |t|
    t.bigint "form_definition_id", null: false
    t.string "name", limit: 100, null: false
    t.integer "category", null: false
    t.jsonb "options", default: {}, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category"], name: "index_dsj_form_fields_on_category"
    t.index ["form_definition_id"], name: "index_dsj_form_fields_on_form_definition_id"
    t.index ["name"], name: "index_dsj_form_fields_on_name"
    t.index ["options"], name: "index_dsj_form_fields_on_options", using: :gin
  end

  create_table "dsj_forms_snippets", force: :cascade do |t|
    t.bigint "form_model_id", null: false
    t.bigint "snippet_id", null: false
    t.index ["form_model_id"], name: "index_dsj_forms_snippets_on_form_model_id"
    t.index ["snippet_id"], name: "index_dsj_forms_snippets_on_snippet_id"
  end

  create_table "dsj_snippets", force: :cascade do |t|
    t.text "raw_text"
    t.string "I18n_key"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["I18n_key"], name: "index_dsj_snippets_on_I18n_key"
  end

  create_table "test_plan_models", force: :cascade do |t|
    t.string "state"
    t.string "reference"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
