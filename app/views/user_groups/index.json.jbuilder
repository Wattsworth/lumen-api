json.owner do
  json.array! @owned_groups do |group|
    json.extract! group, *UserGroup.json_keys
    json.members group.users do |user|
      json.extract! user, *User.json_keys
    end
  end
end
json.member do
  json.array! @member_groups do |group|
    json.extract! group, *UserGroup.json_keys
  end
end
json.other do
  json.array! @other_groups do |group|
    json.extract! group, *UserGroup.json_keys
  end
end
