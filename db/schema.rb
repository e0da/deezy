ActiveRecord::Schema.define(:version => 20100519202433) do

  create_table "hosts", :force => true do |t|
    t.string   "scope"
    t.string   "mac"
    t.string   "ip"
    t.string   "itgid"
    t.string   "hostname"
    t.string   "uid"
    t.boolean  "enabled"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "room"
    t.integer  "ip_int"
  end

end
