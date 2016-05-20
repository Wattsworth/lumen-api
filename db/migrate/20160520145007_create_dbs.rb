class CreateDbs < ActiveRecord::Migration
  def change
    create_table :dbs do |t|
      t.string :url
      t.integer :db_folder_id

      t.timestamps null: false
    end
  end
end
