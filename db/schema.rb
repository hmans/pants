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

ActiveRecord::Schema.define(version: 20140707183206) do

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

  create_table "post_shas", force: true do |t|
    t.integer  "post_id"
    t.string   "sha",        limit: 40
    t.datetime "created_at"
  end

  create_table "posts", force: true do |t|
    t.string   "slug"
    t.string   "domain"
    t.text     "body"
    t.text     "body_html"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.string   "guid"
    t.datetime "edited_at"
    t.string   "url"
    t.string   "referenced_guid"
  end

  add_index "posts", ["guid"], name: "index_posts_on_guid", using: :btree
  add_index "posts", ["referenced_guid"], name: "index_posts_on_referenced_guid", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

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
    t.datetime "last_polled_at"
  end

  add_index "users", ["domain"], name: "index_users_on_domain", unique: true, using: :btree
  add_index "users", ["hosted", "domain"], name: "index_users_on_hosted_and_domain", using: :btree
  add_index "users", ["last_polled_at"], name: "index_users_on_last_polled_at", using: :btree

end
