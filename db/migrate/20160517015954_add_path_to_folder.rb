class AddPathToFolder < ActiveRecord::Migration[5.0]
  def change
    add_column :db_folders, :path, :string
  end
end
