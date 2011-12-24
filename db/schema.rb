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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111223185408) do

  create_table "access_requests", :force => true do |t|
    t.string   "email"
    t.boolean  "granted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "referral_code"
  end

  create_table "album_tracks", :id => false, :force => true do |t|
    t.integer "album_id"
    t.integer "track_id"
  end

  create_table "albums", :force => true do |t|
    t.string   "name",        :limit => 1000
    t.string   "artwork_url"
    t.integer  "external_id"
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "artists", :force => true do |t|
    t.string   "name",        :limit => 1000
    t.integer  "external_id"
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "author_id"
    t.integer  "splash_id"
    t.string   "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "skip_feed"
  end

  add_index "comments", ["author_id"], :name => "index_comments_on_author_id"
  add_index "comments", ["splash_id"], :name => "index_comments_on_splash_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "genres", :force => true do |t|
    t.string   "name",        :limit => 1000
    t.integer  "external_id"
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", :force => true do |t|
    t.integer  "notified_id"
    t.string   "title"
    t.datetime "read_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "notifier_id"
    t.string   "type"
    t.integer  "target_id"
    t.string   "target_type"
  end

  create_table "relationships", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationships", ["followed_id"], :name => "index_relationships_on_followed_id"
  add_index "relationships", ["follower_id", "followed_id"], :name => "index_relationships_on_follower_id_and_followed_id", :unique => true
  add_index "relationships", ["follower_id"], :name => "index_relationships_on_follower_id"

  create_table "social_connections", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "token"
    t.string   "token_secret"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "social_connections", ["uid"], :name => "index_social_connections_on_uid", :unique => true
  add_index "social_connections", ["user_id"], :name => "index_social_connections_on_user_id"

  create_table "splashes", :force => true do |t|
    t.integer  "track_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.string   "splash_list"
    t.string   "user_list"
    t.integer  "comments_count"
  end

  add_index "splashes", ["parent_id"], :name => "index_splashes_on_parent_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
    t.datetime "created_at"
  end

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "external_id"
  end

  create_table "track_genres", :id => false, :force => true do |t|
    t.integer "track_id"
    t.integer "genre_id"
  end

  create_table "track_performers", :id => false, :force => true do |t|
    t.integer "track_id"
    t.integer "artist_id"
  end

  create_table "tracks", :force => true do |t|
    t.string   "title",                :limit => 1000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "data_file_name"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.datetime "data_updated_at"
    t.string   "purchase_url_raw",     :limit => 1024
    t.string   "type"
    t.string   "artwork_url"
    t.integer  "external_id"
    t.string   "preview_url"
    t.text     "performers"
    t.text     "albums"
    t.string   "album_artwork_url"
    t.integer  "popularity_rank"
    t.integer  "uploader_id"
    t.string   "artwork_file_name"
    t.string   "artwork_content_type"
    t.integer  "artwork_file_size"
    t.datetime "artwork_updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => ""
    t.string   "encrypted_password",     :limit => 128, :default => "",     :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "superuser",                             :default => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "type",                                  :default => "User", :null => false
    t.string   "name"
    t.string   "initial_provider"
    t.string   "tagline",                :limit => 60
    t.date     "birthday"
    t.text     "ignore_suggested_users"
    t.text     "suggested_users"
    t.string   "nickname"
    t.text     "avatar_meta"
    t.boolean  "active"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["nickname"], :name => "index_users_on_nickname", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
