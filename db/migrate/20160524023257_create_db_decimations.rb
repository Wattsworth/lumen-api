class CreateDbDecimations < ActiveRecord::Migration
  def change
    create_table :db_decimations do |t|
      t.integer :start_time, :int, :limit=>8
      t.integer :end_time, :int, :limit=>8
      t.integer :total_rows, :int, :limit=>8
      t.integer :total_time, :int, :limit=>8
      t.integer :db_file_id, :int
      t.timestamps null: false
    end
  end
end
