class ChangeEventFieldsName < ActiveRecord::Migration[6.0]
  def change
    rename_column :event_streams, :event_fields, :event_fields_json

  end
end
