class AddJouleInfo < ActiveRecord::Migration[5.2]
  def change
    add_column :nilms, :node_type, :string
    add_column :db_folders, :joule_id, :integer
    add_column :db_streams, :joule_id, :integer
    add_index :db_streams, :joule_id
    add_index :db_folders, :joule_id
  end
end
