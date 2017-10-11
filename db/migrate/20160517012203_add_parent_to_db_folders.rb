class AddParentToDbFolders < ActiveRecord::Migration[5.0]
  def change
    add_column :db_folders, :parent_id, :integer
  end
end
