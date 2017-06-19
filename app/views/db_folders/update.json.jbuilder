json.data do
  json.partial! "db_folders/db_folder", db_folder: @db_folder, nilm: @nilm
end

json.partial! "helpers/messages", service: @service
