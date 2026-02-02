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

ActiveRecord::Schema[8.1].define(version: 2026_01_09_032334) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "announcement_audiences", force: :cascade do |t|
    t.bigint "announcement_id", null: false
    t.bigint "audience_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["announcement_id"], name: "index_announcement_audiences_on_announcement_id"
    t.index ["audience_id"], name: "index_announcement_audiences_on_audience_id"
  end

  create_table "announcement_targets", force: :cascade do |t|
    t.bigint "announcement_id", null: false
    t.datetime "created_at", null: false
    t.bigint "group_id", null: false
    t.datetime "updated_at", null: false
    t.index ["announcement_id"], name: "index_announcement_targets_on_announcement_id"
    t.index ["group_id"], name: "index_announcement_targets_on_group_id"
  end

  create_table "announcements", force: :cascade do |t|
    t.text "base_body"
    t.text "body"
    t.datetime "created_at", null: false
    t.text "email_body"
    t.datetime "scheduled_for"
    t.boolean "send_to_email"
    t.boolean "send_to_slack"
    t.boolean "send_to_whatsapp"
    t.text "slack_body"
    t.string "status"
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.text "whatsapp_body"
    t.index ["user_id"], name: "index_announcements_on_user_id"
  end

  create_table "audience_memberships", force: :cascade do |t|
    t.bigint "audience_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["audience_id"], name: "index_audience_memberships_on_audience_id"
    t.index ["user_id"], name: "index_audience_memberships_on_user_id"
  end

  create_table "audiences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.text "email_recipients"
    t.string "name"
    t.string "slack_channel"
    t.string "type"
    t.datetime "updated_at", null: false
    t.text "whatsapp_recipients"
  end

  create_table "delivery_logs", force: :cascade do |t|
    t.bigint "announcement_id", null: false
    t.string "channel"
    t.datetime "created_at", null: false
    t.string "destination"
    t.text "details"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["announcement_id", "channel", "destination"], name: "idx_on_announcement_id_channel_destination_8922b0421c", unique: true
    t.index ["announcement_id"], name: "index_delivery_logs_on_announcement_id"
  end

  create_table "group_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "group_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["group_id"], name: "index_group_memberships_on_group_id"
    t.index ["user_id"], name: "index_group_memberships_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "name"
    t.string "slack_channel"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "announcement_audiences", "announcements"
  add_foreign_key "announcement_audiences", "audiences"
  add_foreign_key "announcement_targets", "announcements"
  add_foreign_key "announcement_targets", "groups"
  add_foreign_key "announcements", "users"
  add_foreign_key "audience_memberships", "audiences"
  add_foreign_key "audience_memberships", "users"
  add_foreign_key "delivery_logs", "announcements"
  add_foreign_key "group_memberships", "groups"
  add_foreign_key "group_memberships", "users"
end
