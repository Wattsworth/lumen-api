json.data do
  json.partial! "db_folders/db_folder", db_folder: @db_folder, shallow: false
end

json.partial! "helpers/messages", service: @service
