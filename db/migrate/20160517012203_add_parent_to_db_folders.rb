class AddParentToDbFolders < ActiveRecord::Migration
  def change
    add_column :db_folders, :parent_id, :integer
  end
end
