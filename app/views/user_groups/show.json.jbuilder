json.data do
  json.extract! @user_group, *UserGroup.json_keys
  if(@user_group.owner==current_user)
    json.members @user_group.users do |user|
      json.extract! user, *User.json_keys
    end
  end
end

json.partial! "helpers/messages", service: @service
