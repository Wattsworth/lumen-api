json.data do
  json.extract! @data_view, *DataView.json_keys
  json.owner current_user==@data_view.owner
end

json.partial! "helpers/messages", service: @service
