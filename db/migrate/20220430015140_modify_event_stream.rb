class ModifyEventStream < ActiveRecord::Migration[6.0]
  def change
    remove_column :event_streams, :total_rows
    remove_column :event_streams, :total_time
    remove_column :event_streams, :size_on_disk
    add_column :event_streams, :event_count, :integer

  end
end
