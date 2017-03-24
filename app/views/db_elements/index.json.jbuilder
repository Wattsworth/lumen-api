json.data do
  json.array! @service.data.each do |element_data|
    elem = DbElement.find(element_data[:id])
    json.extract! elem, *DbElement.json_keys
    json.path elem.name_path
    json.data element_data[:values]
    json.start_time @start_time
    json.end_time @end_time
  end
end

json.partial! "helpers/messages", service: @service
