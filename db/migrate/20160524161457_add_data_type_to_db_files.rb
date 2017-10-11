class AddDataTypeToDbFiles < ActiveRecord::Migration[5.0]
  def change
    add_column :db_files, :data_type, :string
  end
end
