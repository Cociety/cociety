# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_11_30_070827) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "charges", primary_key: ["external_entity_source_id", "external_event_id", "stripe_id"], force: :cascade do |t|
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.boolean "refunded", default: false
    t.integer "status", null: false
    t.integer "stripe_created"
    t.string "stripe_id", null: false
    t.string "external_event_id", null: false
    t.uuid "external_entity_source_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["external_entity_source_id"], name: "index_charges_on_external_entity_source_id"
    t.index ["external_event_id"], name: "index_charges_on_external_event_id"
    t.index ["stripe_created"], name: "index_charges_on_stripe_created"
    t.index ["stripe_id"], name: "index_charges_on_stripe_id"
  end

  create_table "customer_emails", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email"
    t.uuid "customer_id", null: false
    t.boolean "is_verified", default: false, null: false
    t.boolean "is_default", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["customer_id", "is_default"], name: "index_customer_emails_on_customer_id_and_is_default", unique: true, where: "is_default"
    t.index ["customer_id"], name: "index_customer_emails_on_customer_id"
    t.index ["email"], name: "index_customer_emails_on_email", unique: true
  end

  create_table "customers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "password_digest"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "external_entities", primary_key: ["external_entity_source_id", "external_id"], force: :cascade do |t|
    t.string "external_id", null: false
    t.uuid "external_entity_source_id", null: false
    t.string "internal_entity_type"
    t.uuid "internal_entity_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["external_entity_source_id", "internal_entity_type", "internal_entity_id"], name: "index-entity_id-internal-type_internal-id"
    t.index ["external_entity_source_id"], name: "index_external_entities_on_external_entity_source_id"
    t.index ["internal_entity_type", "internal_entity_id"], name: "index_type_id"
  end

  create_table "external_entity_sources", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "url"
    t.index ["name"], name: "index_external_entity_sources_on_name", unique: true
  end

  create_table "external_events", primary_key: ["external_entity_source_id", "external_event_id"], force: :cascade do |t|
    t.string "external_event_id", null: false
    t.uuid "external_entity_source_id", null: false
    t.json "raw"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["external_entity_source_id", "external_event_id"], name: "index-external_source-external_id"
    t.index ["external_entity_source_id"], name: "index_external_events_on_external_entity_source_id"
  end

  create_table "organization_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "category", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category"], name: "index_organization_categories_on_category", unique: true
  end

  create_table "organization_categories_organizations", id: false, force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.uuid "organization_category_id", null: false
    t.index ["organization_category_id", "organization_id"], name: "category_to_organizations", unique: true
    t.index ["organization_id", "organization_category_id"], name: "organization_to_categories", unique: true
  end

  create_table "organizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "payment_allocation_sets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "customer_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["customer_id"], name: "index_payment_allocation_sets_on_customer_id"
  end

  create_table "payment_allocations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "payment_allocation_set_id", null: false
    t.uuid "organization_id", null: false
    t.integer "percent"
    t.index ["organization_id"], name: "index_payment_allocations_on_organization_id"
    t.index ["payment_allocation_set_id"], name: "index_payment_to_group"
  end

  add_foreign_key "customer_emails", "customers"
end
