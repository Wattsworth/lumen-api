
# frozen_string_literal: true
json.extract! db_stream, *DbStream.json_keys
json.nilm_id db_stream.db.nilm.id

json.elements(db_stream.db_elements) do |element|
  json.extract! element, *DbElement.json_keys
end
