
json.extract! db_folder, :id, :name, :description, :path, :hidden,
                         :start_time, :end_time, :size_on_disk
json.shallow shallow
unless(shallow)
  json.subfolders do
    json.array! db_folder.subfolders, partial: 'db_folders/db_folder',
                as: :db_folder, shallow: true
  end
  json.streams do
    json.array! db_folder.db_streams, partial: 'db_streams/db_stream',
                as: :db_stream
  end
end
