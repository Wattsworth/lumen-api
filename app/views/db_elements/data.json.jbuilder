json.data do
  json.array! @service.data.each do |element_data|
    json.element_id element_data[:id]
    json.data element_data[:values]
    json.type element_data[:type]
    json.start_time @start_time
    json.end_time @end_time
  end
end

json.partial! "helpers/messages", service: @service
