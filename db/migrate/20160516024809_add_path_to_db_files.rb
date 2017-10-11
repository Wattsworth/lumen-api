class AddPathToDbFiles < ActiveRecord::Migration[5.0]
  def change
    add_column :db_files, :path, :string
  end
end
