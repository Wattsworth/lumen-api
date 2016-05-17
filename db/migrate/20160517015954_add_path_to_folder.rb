class AddPathToFolder < ActiveRecord::Migration
  def change
    add_column :db_folders, :path, :string
  end
end
