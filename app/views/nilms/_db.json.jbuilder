json.db do
  json.extract! db, *Db.json_keys

  if(db.root_folder != nil)
    json.contents do
      root = db.root_folder
      json.extract! root, *DbFolder.json_keys

      json.subfolders(root.subfolders) do |folder|
        json.extract! folder, *DbFolder.json_keys
      end

      json.streams(root.db_streams) do |stream|
        json.extract! stream, *DbStream.json_keys
        json.elements(stream.db_elements) do |element|
          json.extract! element, *DbElement.json_keys
        end
      end
    end
  end
end
