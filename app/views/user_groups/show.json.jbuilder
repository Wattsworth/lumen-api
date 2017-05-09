json.data do
  json.extract! @user_group, *UserGroup.json_keys
  if(@user_group.owner==current_user)
    json.members @user_group.users
      .select {|u| u.accepted_or_not_invited? } do |user|
      json.extract! user, *User.json_keys
    end
  end
end

json.partial! "helpers/messages", service: @service
