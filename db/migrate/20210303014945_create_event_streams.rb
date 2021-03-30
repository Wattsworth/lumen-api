class CreateEventStreams < ActiveRecord::Migration[6.0]
  def change
    create_table :event_streams do |t|
      t.belongs_to :db_folder, index: true
      t.belongs_to :db, index: true
      t.string :path
      t.integer :start_time, limit: 8
      t.integer :end_time, limit: 8
      t.integer :total_rows, limit: 8
      t.integer :total_time, limit: 8
      t.integer :size_on_disk, limit: 8
      t.integer :joule_id, index: true
      t.string :name
      t.string :description
      t.timestamps
    end
  end
end
