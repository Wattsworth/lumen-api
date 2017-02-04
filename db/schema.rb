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

ActiveRecord::Schema.define(version: 20170204010933) do

  create_table "db_decimations", force: :cascade do |t|
    t.integer  "start_time",   limit: 8
    t.integer  "end_time",     limit: 8
    t.integer  "total_rows",   limit: 8
    t.integer  "total_time",   limit: 8
    t.integer  "db_stream_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "level",        limit: 8
    t.string   "data_type"
  end

  create_table "db_elements", force: :cascade do |t|
    t.string   "name"
    t.string   "units"
    t.integer  "column"
    t.float    "default_max"
    t.float    "default_min"
    t.float    "scale_factor"
    t.float    "offset"
    t.integer  "db_stream_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.boolean  "plottable"
    t.boolean  "discrete"
  end

  create_table "db_folders", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "parent_id"
    t.string   "path"
    t.boolean  "hidden"
    t.integer  "db_id"
    t.integer  "start_time",   limit: 8
    t.integer  "end_time",     limit: 8
    t.integer  "size_on_disk", limit: 8
  end

  create_table "db_streams", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "db_folder_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "path"
    t.integer  "start_time",    limit: 8
    t.integer  "end_time",      limit: 8
    t.integer  "total_rows",    limit: 8
    t.integer  "total_time",    limit: 8
    t.string   "data_type"
    t.string   "name_abbrev"
    t.boolean  "delete_locked"
    t.boolean  "hidden"
    t.integer  "size_on_disk",  limit: 8
    t.integer  "db_id"
  end

  create_table "dbs", force: :cascade do |t|
    t.string   "url"
    t.integer  "db_folder_id"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "nilm_id"
    t.integer  "size_total",          limit: 8
    t.integer  "size_db",             limit: 8
    t.integer  "size_other",          limit: 8
    t.string   "version"
    t.integer  "max_points_per_plot",           default: 3600
    t.boolean  "available"
  end

  create_table "nilms", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "url"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "provider",               default: "email", null: false
    t.string   "uid",                    default: "",      null: false
    t.string   "encrypted_password",     default: "",      null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.text     "tokens"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

end
