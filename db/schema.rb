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

ActiveRecord::Schema[8.1].define(version: 2025_12_31_190359) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "connections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_1_id", null: false
    t.bigint "user_2_id", null: false
    t.index ["status"], name: "index_connections_on_status"
    t.index ["user_1_id", "user_2_id"], name: "index_connections_on_user_1_id_and_user_2_id", unique: true
    t.index ["user_1_id"], name: "index_connections_on_user_1_id"
    t.index ["user_2_id"], name: "index_connections_on_user_2_id"
  end

  create_table "devices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "platform"
    t.string "token"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_devices_on_user_id"
  end

  create_table "note_versions", force: :cascade do |t|
    t.string "change_type", default: "updated", null: false
    t.string "color"
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "created_by_id", null: false
    t.integer "note_id", null: false
    t.text "title"
    t.datetime "updated_at", null: false
    t.integer "version_number", null: false
    t.index ["created_by_id"], name: "index_note_versions_on_created_by_id"
    t.index ["note_id", "version_number"], name: "index_note_versions_on_note_id_and_version_number", unique: true
    t.index ["note_id"], name: "index_note_versions_on_note_id"
  end

  create_table "notes", force: :cascade do |t|
    t.string "color", default: "default"
    t.datetime "created_at", null: false
    t.datetime "locked_at"
    t.integer "locked_by_id"
    t.boolean "pinned", default: false, null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["locked_by_id"], name: "index_notes_on_locked_by_id"
    t.index ["pinned"], name: "index_notes_on_pinned"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "shared_withs", force: :cascade do |t|
    t.boolean "can_edit", default: false, null: false
    t.datetime "created_at", null: false
    t.integer "note_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["note_id"], name: "index_shared_withs_on_note_id"
    t.index ["user_id"], name: "index_shared_withs_on_user_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "note_id", null: false
    t.integer "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["note_id"], name: "index_taggings_on_note_id"
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "dark_mode", default: false, null: false
    t.string "display_name"
    t.string "email"
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "connections", "users", column: "user_1_id"
  add_foreign_key "connections", "users", column: "user_2_id"
  add_foreign_key "devices", "users"
  add_foreign_key "note_versions", "notes"
  add_foreign_key "note_versions", "users", column: "created_by_id"
  add_foreign_key "notes", "users"
  add_foreign_key "notes", "users", column: "locked_by_id"
  add_foreign_key "shared_withs", "notes"
  add_foreign_key "shared_withs", "users"
  add_foreign_key "taggings", "notes"
  add_foreign_key "taggings", "tags"
end
