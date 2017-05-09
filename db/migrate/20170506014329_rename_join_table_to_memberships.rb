class RenameJoinTableToMemberships < ActiveRecord::Migration[5.0]
  def change
    rename_table :user_groups_users, :memberships
  end
end
