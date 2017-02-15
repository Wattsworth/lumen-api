class AddUserGroupsJoinTable < ActiveRecord::Migration[5.0]
  def change
    create_table :user_groups_users, id: false do |t|
      t.integer :user_group_id
      t.integer :user_id
    end
    add_index :user_groups_users, :user_group_id
    add_index :user_groups_users, :user_id
  end
end
