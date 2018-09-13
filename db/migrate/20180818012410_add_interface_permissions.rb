class AddInterfacePermissions < ActiveRecord::Migration[5.2]
  def change
    create_table "interface_permissions", :force => true do |t|

      t.integer  "interface_id"
      t.datetime "created_at",      :null => false
      t.datetime "updated_at",      :null => false
      t.integer  "user_id"
      t.integer  "user_group_id"
      t.string   "role"
      t.integer  "precedence"
      t.index :interface_id
    end
  end
end
