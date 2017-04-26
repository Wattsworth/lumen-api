class RenameType < ActiveRecord::Migration[5.0]
  def change
    rename_column :db_elements, :type, :display_type

  end
end
