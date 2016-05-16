class AddPathToDbFiles < ActiveRecord::Migration
  def change
    add_column :db_files, :path, :string
  end
end
