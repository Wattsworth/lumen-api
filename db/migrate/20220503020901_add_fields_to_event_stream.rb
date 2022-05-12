class AddFieldsToEventStream < ActiveRecord::Migration[6.0]
  def change
    add_column :event_streams, :event_fields, :string

  end
end
