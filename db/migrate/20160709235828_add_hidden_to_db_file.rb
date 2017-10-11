class AddHiddenToDbFile < ActiveRecord::Migration[5.0]
  def change
    add_column :db_files, :hidden, :boolean
    add_column :db_folders, :hidden, :boolean
  end
end
