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

ActiveRecord::Schema.define(version: 20140629162248) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "friendships", force: true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "created_at"
  end

  add_index "friendships", ["friend_id"], name: "index_friendships_on_friend_id", using: :btree
  add_index "friendships", ["user_id", "friend_id"], name: "index_friendships_on_user_id_and_friend_id", unique: true, using: :btree
  add_index "friendships", ["user_id"], name: "index_friendships_on_user_id", using: :btree

  create_table "posts", force: true do |t|
    t.string   "sha",             limit: 40
    t.string   "slug"
    t.string   "domain"
    t.text     "body"
    t.text     "body_html"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "tags",                       default: [], array: true
    t.text     "previous_shas",              default: [], array: true
    t.datetime "published_at"
    t.string   "guid"
    t.datetime "edited_at"
    t.string   "url"
    t.string   "referenced_guid"
  end

  add_index "posts", ["guid"], name: "index_posts_on_guid", using: :btree
  add_index "posts", ["previous_shas"], name: "index_posts_on_previous_shas", using: :gin
  add_index "posts", ["referenced_guid"], name: "index_posts_on_referenced_guid", using: :btree
  add_index "posts", ["tags"], name: "index_posts_on_tags", using: :gin

  create_table "timeline_entries", force: true do |t|
    t.integer  "user_id"
    t.integer  "post_id"
    t.datetime "created_at"
    t.boolean  "from_friend", default: false, null: false
  end

  add_index "timeline_entries", ["post_id"], name: "index_timeline_entries_on_post_id", using: :btree
  add_index "timeline_entries", ["user_id", "created_at"], name: "index_timeline_entries_on_user_id_and_created_at", using: :btree
  add_index "timeline_entries", ["user_id", "post_id"], name: "index_timeline_entries_on_user_id_and_post_id", unique: true, using: :btree
  add_index "timeline_entries", ["user_id"], name: "index_timeline_entries_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "domain"
    t.string   "display_name"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "locale",              limit: 5,  default: "en"
    t.string   "url"
    t.boolean  "hosted",                         default: false, null: false
    t.string   "gosquared_id",        limit: 20
    t.string   "image_uid"
    t.string   "google_analytics_id", limit: 20
  end

  add_index "users", ["domain"], name: "index_users_on_domain", unique: true, using: :btree
  add_index "users", ["hosted", "domain"], name: "index_users_on_hosted_and_domain", using: :btree

end
