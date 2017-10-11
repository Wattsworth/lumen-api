class CreateDbFiles < ActiveRecord::Migration[5.0]
  def change
    create_table :db_files do |t|
      t.string :name
      t.string :description
      t.integer :db_folder_id

      t.timestamps null: false
    end
  end
end
