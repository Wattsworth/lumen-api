class CreateJouleModules < ActiveRecord::Migration[5.1]
  def change
    create_table :joule_modules do |t|
      t.string :name
      t.string :description
      t.boolean :web_interface
      t.string :exec_cmd
      t.string :status
      t.integer :pid
      t.string :joule_id
      t.belongs_to :nilm, index: true
      t.timestamps
    end
    create_table :joule_pipes do |t|
      t.belongs_to :joule_pipe, index: true
      t.belongs_to :joule_module, index: true
      t.belongs_to :db_stream, index: true
      t.string :name
      t.string :direction
      t.timestamps
    end
  end
end
