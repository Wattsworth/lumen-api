json.extract! db_folder, *DbFolder.json_keys

json.subfolders(db_folder.subfolders) do |folder|
  json.extract! folder, *DbFolder.json_keys
end

json.streams(db_folder.db_streams.includes(:db_elements)) do |stream|
  json.extract! stream, *DbStream.json_keys
  json.nilm_id nilm.id
  json.elements(stream.db_elements) do |element|
    json.extract! element, *DbElement.json_keys
  end
end
