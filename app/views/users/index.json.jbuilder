json.array! @users do |user|
  json.extract! user, *User.json_keys
end
