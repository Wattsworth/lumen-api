class AddPrimaryKeysToJoinTables < ActiveRecord::Migration[5.0]
  def change
    add_column :data_views_nilms, :id, :primary_key
    add_column :memberships, :id, :primary_key
  end
end
