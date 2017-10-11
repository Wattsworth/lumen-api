class FixDbFolderAttr < ActiveRecord::Migration[5.0]
  def change
    rename_column :db_folders, :end_ime, :end_time
  end
end
