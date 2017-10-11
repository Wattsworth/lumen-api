class CreateDbStreams < ActiveRecord::Migration[5.0]
  def change
    create_table :db_streams do |t|
      t.string :name
      t.string :units
      t.integer :column
      t.float :default_max
      t.float :default_min
      t.float :scale
      t.float :offset
      t.integer :db_file_id
      t.timestamps null: false
    end
  end
end
