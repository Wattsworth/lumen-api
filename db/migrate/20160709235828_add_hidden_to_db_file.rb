class AddHiddenToDbFile < ActiveRecord::Migration
  def change
    add_column :db_files, :hidden, :boolean
    add_column :db_folders, :hidden, :boolean
  end
end
