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

ActiveRecord::Schema[8.1].define(version: 2026_09_07_000201) do
  create_table "accounts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "join_code", null: false
    t.string "name", default: "京チカ", null: false
    t.integer "singleton_guard", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["join_code"], name: "index_accounts_on_join_code", unique: true
    t.index ["singleton_guard"], name: "index_accounts_on_singleton_guard", unique: true
  end

  create_table "landmarks", force: :cascade do |t|
    t.string "answer1"
    t.string "answer2"
    t.string "answer3"
    t.integer "correct"
    t.datetime "created_at", null: false
    t.integer "creator_id"
    t.string "hiragana"
    t.float "latitude"
    t.float "longitude"
    t.string "name"
    t.string "question"
    t.datetime "updated_at", null: false
    t.string "url"
    t.datetime "url_checked_at"
    t.string "url_status"
    t.index ["creator_id"], name: "index_landmarks_on_creator_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "last_active_at", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["token"], name: "index_sessions_on_token", unique: true
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "landmark_id", null: false
    t.integer "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["landmark_id"], name: "index_taggings_on_landmark_id"
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "landmarks", "users", column: "creator_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "taggings", "landmarks"
  add_foreign_key "taggings", "tags"
end
