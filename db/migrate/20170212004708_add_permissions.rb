class AddPermissions < ActiveRecord::Migration[5.0]
  def change

    create_table "permissions", :force => true do |t|
    t.integer  "installation_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "user_id"
    t.integer  "user_group_id"
    t.string   "role"
  end
  
  end
end
