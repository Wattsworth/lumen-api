class CreateDbFolders < ActiveRecord::Migration[5.0]
  def change
    create_table :db_folders do |t|
      t.string :name
      t.string :description

      t.timestamps null: false
    end
  end
end
