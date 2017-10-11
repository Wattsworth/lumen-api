class AddItemsToDbFolders < ActiveRecord::Migration[5.0]
  def change
    add_column :db_folders, :db_id, :integer
    add_column :db_folders, :start_time, :integer, limit: 8
    add_column :db_folders, :end_ime, :integer, limit: 8
    add_column :db_folders, :size_on_disk, :integer

    add_column :db_streams, :size_on_disk, :integer
  end
end
