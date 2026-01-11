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

ActiveRecord::Schema[7.0].define(version: 2026_01_11_043230) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "actual_outfit_contacts", force: :cascade do |t|
    t.bigint "actual_outfit_id", null: false
    t.bigint "contact_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actual_outfit_id"], name: "index_actual_outfit_contacts_on_actual_outfit_id"
    t.index ["contact_id"], name: "index_actual_outfit_contacts_on_contact_id"
  end

  create_table "actual_outfit_items", force: :cascade do |t|
    t.bigint "actual_outfit_id", null: false
    t.bigint "item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actual_outfit_id"], name: "index_actual_outfit_items_on_actual_outfit_id"
    t.index ["item_id"], name: "index_actual_outfit_items_on_item_id"
  end

  create_table "actual_outfits", force: :cascade do |t|
    t.date "worn_on", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "time_slot"
    t.text "impression"
    t.text "memo"
    t.string "title"
    t.string "color"
    t.time "start_time"
    t.index ["user_id"], name: "index_actual_outfits_on_user_id"
    t.index ["worn_on"], name: "index_actual_outfits_on_worn_on"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "contacts", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_favorite", default: false, null: false
    t.integer "category", default: 0
    t.index ["user_id"], name: "index_contacts_on_user_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "price"
    t.string "color"
    t.bigint "user_id", null: false
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "wash_frequency", default: 1, null: false
    t.integer "wears_count", default: 0, null: false
    t.integer "total_washes", default: 0, null: false
    t.boolean "is_private", default: false, null: false
    t.index ["category_id"], name: "index_items_on_category_id"
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "outfit_contacts", force: :cascade do |t|
    t.bigint "actual_outfit_id", null: false
    t.bigint "contact_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actual_outfit_id"], name: "index_outfit_contacts_on_actual_outfit_id"
    t.index ["contact_id"], name: "index_outfit_contacts_on_contact_id"
  end

  create_table "outfit_items", force: :cascade do |t|
    t.bigint "actual_outfit_id", null: false
    t.bigint "item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actual_outfit_id"], name: "index_outfit_items_on_actual_outfit_id"
    t.index ["item_id"], name: "index_outfit_items_on_item_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "actual_outfit_contacts", "actual_outfits"
  add_foreign_key "actual_outfit_contacts", "contacts"
  add_foreign_key "actual_outfit_items", "actual_outfits"
  add_foreign_key "actual_outfit_items", "items"
  add_foreign_key "actual_outfits", "users"
  add_foreign_key "contacts", "users"
  add_foreign_key "items", "categories"
  add_foreign_key "items", "users"
  add_foreign_key "outfit_contacts", "actual_outfits"
  add_foreign_key "outfit_contacts", "contacts"
  add_foreign_key "outfit_items", "actual_outfits"
  add_foreign_key "outfit_items", "items"
end
