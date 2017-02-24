json.array! @user_groups do |group|
  json.extract! group, *UserGroup.json_keys
end
