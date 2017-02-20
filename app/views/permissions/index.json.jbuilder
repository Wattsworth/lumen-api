json.array!(@permissions) do |permission|
  json.extract! permission, *Permission.json_keys
  json.name permission.target_name
end
