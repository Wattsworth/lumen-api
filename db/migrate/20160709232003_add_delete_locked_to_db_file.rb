class AddDeleteLockedToDbFile < ActiveRecord::Migration
  def change
    add_column :db_files, :delete_locked, :boolean
  end
end
