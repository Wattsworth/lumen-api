class AddFieldsToFile < ActiveRecord::Migration
  def change
    add_column :db_decimations, :level, :integer
    add_column :db_files, :start_time, :integer, limit: 8
    add_column :db_files, :end_time, :integer, limit: 8
    add_column :db_files, :total_rows, :integer, limit: 8
    add_column :db_files, :total_time, :integer, limit: 8
  end
end
