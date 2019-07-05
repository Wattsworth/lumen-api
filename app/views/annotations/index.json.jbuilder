json.data do
  json.array!(@annotations) do |annotation|
    json.extract! annotation, *Annotation.json_keys
    json.start annotation.start_time
    json.end annotation.end_time
    json.db_stream_id annotation.db_stream.id
  end
end

json.partial! "helpers/messages", service: @service