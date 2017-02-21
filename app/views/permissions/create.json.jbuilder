json.data do
  json.extract! @permission, *Permission.json_keys
  json.target_name @permission.target_name
  json.target_type @permission.target_type
end

json.partial! "helpers/messages", service: @service
