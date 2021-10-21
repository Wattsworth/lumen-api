class CreateDbDecimations < ActiveRecord::Migration[5.0]
  def change
    create_table :db_decimations do |t|
      t.integer :start_time, :limit=>8
      t.integer :end_time, :limit=>8
      t.integer :total_rows, :limit=>8
      t.integer :total_time, :limit=>8
      t.integer :db_file_id
      t.timestamps null: false
    end
  end
end
