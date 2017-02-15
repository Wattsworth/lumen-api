json.data do
  json.partial! "dbs/db", db: @db
end

json.partial! "helpers/messages", service: @service
