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

ActiveRecord::Schema.define(version: 20150423170001) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assignments", force: :cascade do |t|
    t.integer  "track_id",    null: false
    t.integer  "playlist_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "assignments", ["track_id", "playlist_id"], name: "index_assignments_on_track_id_and_playlist_id", unique: true, using: :btree

  create_table "follows", force: :cascade do |t|
    t.integer  "playlist_id", null: false
    t.integer  "user_id",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "genres", force: :cascade do |t|
    t.integer  "group_id",   default: 16,   null: false
    t.string   "name",                      null: false
    t.string   "popularity", default: "20", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", force: :cascade do |t|
    t.string "rgb", default: "(100, 100, 100)", null: false
  end

  create_table "playlists", force: :cascade do |t|
    t.string   "name",                          null: false
    t.integer  "user_id",                       null: false
    t.string   "spotify_id",                    null: false
    t.string   "link",                          null: false
    t.string   "seed_artist"
    t.integer  "assignment_id"
    t.string   "snapshot_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "adventurous",   default: false
    t.float    "familiarity",   default: 0.0
    t.integer  "tempo",         default: 0
    t.float    "danceability",  default: 0.0
    t.text     "uri_array",     default: "[]"
    t.integer  "follows_cache", default: 0
  end

  create_table "styles", force: :cascade do |t|
    t.integer  "playlist_id", null: false
    t.integer  "genre_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "styles", ["genre_id", "playlist_id"], name: "index_styles_on_genre_id_and_playlist_id", unique: true, using: :btree

  create_table "tracks", force: :cascade do |t|
    t.string   "artist_name",    null: false
    t.string   "echonest_id",    null: false
    t.string   "spotify_id",     null: false
    t.string   "title",          null: false
    t.integer  "key"
    t.integer  "mode"
    t.float    "energy"
    t.float    "liveness"
    t.float    "tempo"
    t.integer  "time_signature"
    t.float    "danceability"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",                           null: false
    t.string   "email",         default: ""
    t.string   "spotify_id",                     null: false
    t.string   "spotify_link",  default: ""
    t.string   "image"
    t.string   "country",       default: ""
    t.string   "role",          default: "user"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "session_token", default: ""
    t.string   "refresh_token", default: ""
  end

  add_index "users", ["spotify_id"], name: "index_users_on_spotify_id", unique: true, using: :btree

end
