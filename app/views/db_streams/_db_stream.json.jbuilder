
# frozen_string_literal: true
json.extract! db_stream, :id, :name, :description, :path, :start_time,
              :end_time, :size_on_disk, :total_rows, :total_time,
              :data_type, :name_abbrev, :delete_locked, :hidden

json.elements do
  json.array! db_stream.db_elements,
              partial: 'db_streams/db_element',
              as: :db_element
end
