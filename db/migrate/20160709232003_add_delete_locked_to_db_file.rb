class AddDeleteLockedToDbFile < ActiveRecord::Migration[5.0]
  def change
    add_column :db_files, :delete_locked, :boolean
  end
end
