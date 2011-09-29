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

ActiveRecord::Schema.define(:version => 11) do

  create_table "debts", :force => true do |t|
    t.integer  "creator_id",        :default => 0,  :null => false
    t.date     "date",                              :null => false
    t.date     "completed"
    t.text     "description",                       :null => false
    t.string   "name",              :default => "", :null => false
    t.integer  "image_id",          :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "permissions_level", :default => 1,  :null => false
  end

  create_table "debts_tags", :id => false, :force => true do |t|
    t.integer  "tag_id",     :default => 0, :null => false
    t.integer  "debt_id",    :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", :force => true do |t|
    t.integer "parent_id"
    t.string  "content_type"
    t.string  "filename"
    t.string  "thumbnail"
    t.integer "size"
    t.integer "width"
    t.integer "height"
  end

  create_table "payments", :force => true do |t|
    t.integer  "payee_id",                                       :default => 0, :null => false
    t.integer  "payor_id",                                       :default => 0, :null => false
    t.integer  "transaction_type",                               :default => 0, :null => false
    t.date     "date",                                                          :null => false
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "amount",           :precision => 9, :scale => 2,                :null => false
  end

  create_table "tags", :force => true do |t|
    t.string   "name",       :default => "", :null => false
    t.integer  "user_id",    :default => 0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_debts", :force => true do |t|
    t.integer  "user_id",                      :default => 0,    :null => false
    t.integer  "debt_id",                      :default => 0,    :null => false
    t.float    "credit_amount",  :limit => 11, :default => 0.0,  :null => false
    t.float    "debit_amount",   :limit => 11, :default => 0.0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_outstanding",               :default => true
  end

  create_table "users", :force => true do |t|
  end

end
