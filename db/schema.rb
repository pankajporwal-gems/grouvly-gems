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

ActiveRecord::Schema.define(version: 20170105140833) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "cards", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "token",       null: false
    t.integer  "bin",         null: false
    t.string   "card_type",   null: false
    t.integer  "last_digits", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "cards", ["user_id"], name: "index_cards_on_user_id", using: :btree

  create_table "credits", force: :cascade do |t|
    t.integer  "user_id"
    t.float    "amount",     default: 0.0
    t.string   "action"
    t.string   "activity"
    t.integer  "actor_id",                    null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "currency",                    null: false
    t.string   "actor_type", default: "User", null: false
  end

  add_index "credits", ["user_id"], name: "index_credits_on_user_id", using: :btree

  create_table "friendships", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "friend_id",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "friendships", ["friend_id"], name: "index_friendships_on_friend_id", using: :btree
  add_index "friendships", ["user_id"], name: "index_friendships_on_user_id", using: :btree

  create_table "matched_reservation_transitions", force: :cascade do |t|
    t.string   "to_state",                            null: false
    t.json     "metadata",               default: {}
    t.integer  "sort_key",                            null: false
    t.integer  "matched_reservation_id",              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "matched_reservation_transitions", ["matched_reservation_id"], name: "index_matched_reservation_transitions_on_matched_reservation_id", using: :btree
  add_index "matched_reservation_transitions", ["sort_key", "matched_reservation_id"], name: "by_sort_key_and_matched_reservation_id", unique: true, using: :btree

  create_table "matched_reservations", force: :cascade do |t|
    t.integer  "first_reservation_id",  null: false
    t.integer  "second_reservation_id", null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.datetime "schedule"
  end

  add_index "matched_reservations", ["first_reservation_id"], name: "index_matched_reservations_on_first_reservation_id", using: :btree
  add_index "matched_reservations", ["second_reservation_id"], name: "index_matched_reservations_on_second_reservation_id", using: :btree

  create_table "payments", force: :cascade do |t|
    t.integer  "reservation_id",                           null: false
    t.float    "amount",                                   null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "currency",                                 null: false
    t.string   "status"
    t.string   "message"
    t.string   "method",             default: "authorize"
    t.integer  "card_id"
    t.string   "transaction_id"
    t.integer  "voucher_id"
    t.string   "transaction_status"
  end

  add_index "payments", ["card_id"], name: "index_payments_on_card_id", using: :btree
  add_index "payments", ["id", "voucher_id"], name: "index_payments_on_id_and_voucher_id", unique: true, using: :btree
  add_index "payments", ["reservation_id"], name: "index_payments_on_reservation_id", using: :btree

  create_table "referrals", force: :cascade do |t|
    t.integer  "user_id",     null: false
    t.integer  "referral_id", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "referrals", ["referral_id"], name: "index_referrals_on_referral_id", using: :btree
  add_index "referrals", ["user_id"], name: "index_referrals_on_user_id", using: :btree

  create_table "refunds", force: :cascade do |t|
    t.integer  "reservation_id"
    t.integer  "payment_id"
    t.integer  "card_id"
    t.decimal  "amount"
    t.string   "currency"
    t.string   "status"
    t.text     "messages"
    t.string   "transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reservation_transitions", force: :cascade do |t|
    t.string   "to_state",                    null: false
    t.json     "metadata",       default: {}
    t.integer  "sort_key",                    null: false
    t.integer  "reservation_id",              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reservation_transitions", ["reservation_id"], name: "index_reservation_transitions_on_reservation_id", using: :btree
  add_index "reservation_transitions", ["sort_key", "reservation_id"], name: "index_reservation_transitions_on_sort_key_and_reservation_id", unique: true, using: :btree

  create_table "reservations", force: :cascade do |t|
    t.integer  "user_id",                             null: false
    t.datetime "schedule",                            null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "slug"
    t.string   "user_type"
    t.boolean  "is_roll",             default: false
    t.string   "updated_by"
    t.boolean  "last_minute_booking", default: false
    t.integer  "wing_quantity",       default: 2
  end

  add_index "reservations", ["slug"], name: "index_reservations_on_slug", using: :btree
  add_index "reservations", ["user_id"], name: "index_reservations_on_user_id", using: :btree

  create_table "unmatched_reservation_histories", force: :cascade do |t|
    t.integer  "reservation_id"
    t.integer  "user_id"
    t.datetime "schedule"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "user_infos", force: :cascade do |t|
    t.integer  "user_id",                              null: false
    t.string   "email_address"
    t.string   "gender_to_match"
    t.string   "location"
    t.string   "phone"
    t.string   "current_work"
    t.string   "studied_at"
    t.string   "religion"
    t.string   "importance_of_religion"
    t.string   "ethnicity"
    t.string   "importance_of_ethnicity"
    t.string   "neighborhood"
    t.string   "height"
    t.datetime "last_facebook_update"
    t.string   "small_profile_picture"
    t.string   "normal_profile_picture"
    t.string   "large_profile_picture"
    t.date     "birthday"
    t.json     "work_history"
    t.json     "education_history"
    t.json     "likes"
    t.string   "gender"
    t.string   "current_employer"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.text     "photos",                  default: [],              array: true
    t.string   "work_category"
    t.string   "origin"
    t.string   "lifestyle"
    t.text     "linkedin_link"
    t.string   "hometown"
    t.string   "meet_new_people_age"
    t.string   "native_place"
    t.string   "hang_out_with"
    t.string   "typical_weekend"
    t.string   "neighborhoods"
    t.string   "meet_new_people_ages"
    t.string   "typical_weekends"
  end

  add_index "user_infos", ["user_id"], name: "index_user_infos_on_user_id", using: :btree

  create_table "user_notes", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "content",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_notes", ["user_id"], name: "index_user_notes_on_user_id", using: :btree

  create_table "user_transitions", force: :cascade do |t|
    t.string   "to_state"
    t.json     "metadata",   default: {}
    t.integer  "sort_key"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_transitions", ["sort_key", "user_id"], name: "index_user_transitions_on_sort_key_and_user_id", unique: true, using: :btree
  add_index "user_transitions", ["user_id"], name: "index_user_transitions_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "provider",                                null: false
    t.string   "uid",                                     null: false
    t.string   "first_name",                              null: false
    t.string   "last_name",                               null: false
    t.string   "oauth_token",                             null: false
    t.datetime "oauth_expires_at",                        null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "slug"
    t.string   "membership_type",     default: "regular"
    t.string   "code"
    t.string   "customer_id"
    t.string   "acquisition_source"
    t.string   "acquisition_channel"
    t.integer  "session_count",       default: 0
  end

  add_index "users", ["code"], name: "index_users_on_code", using: :btree
  add_index "users", ["customer_id"], name: "index_users_on_customer_id", unique: true, using: :btree
  add_index "users", ["provider"], name: "index_users_on_provider", using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", unique: true, using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid", using: :btree

  create_table "venue_booking_notifications", force: :cascade do |t|
    t.integer  "venue_booking_id"
    t.integer  "matched_reservation_id"
    t.integer  "reservation_id"
    t.string   "slug"
    t.boolean  "acknowledged",           default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "venue_booking_notifications", ["matched_reservation_id"], name: "index_venue_booking_notifications_on_matched_reservation_id", using: :btree
  add_index "venue_booking_notifications", ["reservation_id"], name: "index_venue_booking_notifications_on_reservation_id", using: :btree
  add_index "venue_booking_notifications", ["venue_booking_id"], name: "index_venue_booking_notifications_on_venue_booking_id", using: :btree

  create_table "venue_booking_transitions", force: :cascade do |t|
    t.string   "to_state",                      null: false
    t.json     "metadata",         default: {}
    t.integer  "sort_key",                      null: false
    t.integer  "venue_booking_id",              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "venue_booking_transitions", ["sort_key", "venue_booking_id"], name: "index_venue_booking_transitions_", unique: true, using: :btree
  add_index "venue_booking_transitions", ["venue_booking_id"], name: "index_venue_booking_transitions_on_venue_booking_id", using: :btree

  create_table "venue_bookings", force: :cascade do |t|
    t.integer  "venue_id",               null: false
    t.integer  "matched_reservation_id", null: false
    t.datetime "schedule",               null: false
    t.string   "slug"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "venue_bookings", ["matched_reservation_id"], name: "index_venue_bookings_on_matched_reservation_id", using: :btree
  add_index "venue_bookings", ["slug"], name: "index_venue_bookings_on_slug", using: :btree
  add_index "venue_bookings", ["venue_id"], name: "index_venue_bookings_on_venue_id", using: :btree

  create_table "venues", force: :cascade do |t|
    t.string   "name",                                 null: false
    t.string   "venue_type",                           null: false
    t.string   "location",                             null: false
    t.string   "neighborhood",                         null: false
    t.string   "owner_name",                           null: false
    t.string   "owner_email",                          null: false
    t.string   "owner_phone",                          null: false
    t.string   "manager_name",                         null: false
    t.string   "manager_email",                        null: false
    t.string   "manager_phone",                        null: false
    t.boolean  "is_free",              default: false, null: false
    t.text     "map_link",                             null: false
    t.text     "directions",                           null: false
    t.integer  "capacity",                             null: false
    t.hstore   "booking_availability", default: {},    null: false
    t.text     "note"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.datetime "deleted_at"
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "vouchers", force: :cascade do |t|
    t.string   "description",  null: false
    t.string   "voucher_type", null: false
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "quantity"
    t.string   "gender"
    t.integer  "user_id"
    t.string   "restriction"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "slug"
    t.float    "amount",       null: false
  end

  add_index "vouchers", ["slug"], name: "index_vouchers_on_slug", using: :btree
  add_index "vouchers", ["user_id"], name: "index_vouchers_on_user_id", using: :btree

  add_foreign_key "user_infos", "users"
  add_foreign_key "venue_bookings", "matched_reservations"
  add_foreign_key "venue_bookings", "venues"
end
