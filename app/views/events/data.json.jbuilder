json.data do
  json.array! @service.data.each do |event_stream|
    json.id event_stream[:id]
    json.valid event_stream[:valid]
    json.type event_stream[:type]
    json.count event_stream[:count]
    json.events event_stream[:events]
    json.tag event_stream[:tag]
    json.start_time @start_time
    json.end_time @end_time
  end
end


json.partial! "helpers/messages", service: @service