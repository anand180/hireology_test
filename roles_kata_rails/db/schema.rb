ActiveRecord::Schema.define(:version => 20140728200351) do
  create_table "organizations", :force => true do |t|
    t.integer  "parent_organization_id", :null => false
    t.integer  "organization_id"
    t.string   "organization_type", :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name", :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "roles", :force => true do |t|
    t.integer  "user_id", :null => false
    t.integer  "organization_id", :null => false
    t.string   "role_type", :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end
end