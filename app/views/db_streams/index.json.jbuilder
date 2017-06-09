json.array! @streams do |stream|
  json.extract! stream, *DbStream.json_keys
  json.nilm_id stream.db.nilm.id
  json.elements(stream.db_elements) do |element|
    json.extract! element, *DbElement.json_keys
  end
end
