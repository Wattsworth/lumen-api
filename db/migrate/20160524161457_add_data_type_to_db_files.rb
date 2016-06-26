class AddDataTypeToDbFiles < ActiveRecord::Migration
  def change
    add_column :db_files, :data_type, :string
  end
end
