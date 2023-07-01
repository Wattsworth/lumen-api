class AddTimestampsToFoldersAndStreams < ActiveRecord::Migration[7.0]
  def change
    add_column :db_folders, :last_update, :timestamp, default: DateTime.new(1970,1,1,0,0,0)
    add_column :db_streams, :last_update, :timestamp, default: DateTime.new(1970,1,1,0,0,0)
    add_column :event_streams, :last_update, :timestamp, default: DateTime.new(1970,1,1,0,0,0)

  end
end
