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

ActiveRecord::Schema.define(version: 20160709235828) do

  create_table "db_decimations", force: :cascade do |t|
    t.integer  "start_time", limit: 8
    t.integer  "end_time",   limit: 8
    t.integer  "total_rows", limit: 8
    t.integer  "total_time", limit: 8
    t.integer  "db_file_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "level"
    t.string   "data_type"
  end

  create_table "db_files", force: :cascade do |t|
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
  end

  create_table "db_folders", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "parent_id"
    t.string   "path"
    t.boolean  "hidden"
  end

  create_table "db_streams", force: :cascade do |t|
    t.string   "name"
    t.string   "units"
    t.integer  "column"
    t.float    "default_max"
    t.float    "default_min"
    t.float    "scale_factor"
    t.float    "offset"
    t.integer  "db_file_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.boolean  "plottable"
    t.boolean  "discrete"
  end

  create_table "dbs", force: :cascade do |t|
    t.string   "url"
    t.integer  "db_folder_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "nilm_id"
  end

  create_table "nilms", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "url"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

end
