json.data do
  json.extract! @data_view, *DataView.json_keys
  json.owner current_user==@data_view.owner
  json.home current_user.home_data_view_id == @data_view.id
end

json.partial! "helpers/messages", service: @service
