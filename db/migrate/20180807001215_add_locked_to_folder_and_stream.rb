class AddLockedToFolderAndStream < ActiveRecord::Migration[5.2]
  def change
    add_column :db_streams, :locked, :boolean
    add_column :db_folders, :locked, :boolean
  end
end
