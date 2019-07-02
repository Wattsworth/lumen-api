json.data do
  json.id @annotation.id
  json.title @annotation.title
  json.content @annotation.content
  json.start @annotation.start_time
  json.end @annotation.end_time
  json.db_stream_id @db_stream.id
end

json.partial! "helpers/messages", service: @service