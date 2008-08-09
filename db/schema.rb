# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080520201126) do

  create_table "roles", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
  end

  create_table "user_roles", :force => true do |t|
    t.integer  "role_id",    :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at"
  end

  add_index "user_roles", ["role_id"], :name => "index_user_roles_on_role_id"
  add_index "user_roles", ["user_id"], :name => "index_user_roles_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "username",                                                  :null => false
    t.string   "email",                                                     :null => false
    t.string   "crypted_password",          :limit => 40,                   :null => false
    t.string   "salt",                      :limit => 40,                   :null => false
    t.string   "password_reset_code",       :limit => 40
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "ip_address"
    t.boolean  "enabled",                                 :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
