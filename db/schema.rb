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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130412200636) do

  create_table "authentications", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "token"
    t.string   "secret"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 5
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "sidekiq_jobs", :force => true do |t|
    t.string   "jid"
    t.string   "queue"
    t.string   "class_name"
    t.text     "args"
    t.boolean  "retry"
    t.datetime "enqueued_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string   "status"
    t.string   "name"
    t.text     "result"
  end

  add_index "sidekiq_jobs", ["class_name"], :name => "index_sidekiq_jobs_on_class_name"
  add_index "sidekiq_jobs", ["enqueued_at"], :name => "index_sidekiq_jobs_on_enqueued_at"
  add_index "sidekiq_jobs", ["finished_at"], :name => "index_sidekiq_jobs_on_finished_at"
  add_index "sidekiq_jobs", ["jid"], :name => "index_sidekiq_jobs_on_jid"
  add_index "sidekiq_jobs", ["queue"], :name => "index_sidekiq_jobs_on_queue"
  add_index "sidekiq_jobs", ["retry"], :name => "index_sidekiq_jobs_on_retry"
  add_index "sidekiq_jobs", ["started_at"], :name => "index_sidekiq_jobs_on_started_at"
  add_index "sidekiq_jobs", ["status"], :name => "index_sidekiq_jobs_on_status"


  create_table "users", :force => true do |t|
    t.string   "email",                                :default => "",    :null => false
    t.string   "encrypted_password",                   :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "password_salt"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",                      :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.string   "invitation_token",       :limit => 60
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.string   "full_name"
    t.string   "vault_token"
    t.integer  "subscription_plan_id"
    t.integer  "coupon_id"
    t.boolean  "admin",                                :default => false
    t.string   "lazy_id"
    t.text     "dashboards_last_read"
  end

  add_index "users", ["coupon_id"], :name => "index_users_on_coupon_id"
  add_index "users", ["created_at"], :name => "index_users_on_created_at"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["subscription_plan_id"], :name => "index_users_on_subscription_plan_id"
  add_index "users", ["vault_token"], :name => "index_users_on_vault_token"

end
