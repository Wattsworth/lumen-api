
# frozen_string_literal: true
json.extract! db_stream, *DbStream.json_keys

json.elements(db_stream.db_elements) do |element|
  json.extract! element, *DbElement.json_keys
end
