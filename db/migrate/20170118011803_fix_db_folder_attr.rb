class FixDbFolderAttr < ActiveRecord::Migration
  def change
    rename_column :db_folders, :end_ime, :end_time
  end
end
