# frozen_string_literal: true

# Handles adding users to a group
class AddGroupMember
  include ServiceStatus
  attr_reader :user_group

  def run(user_group, user_id)
    # add user specified by [user_id] to the group
    @user_group = user_group
    user = User.find_by_id(user_id)
    if user.nil?
      add_error("invalid user_id")
      return self
    end
    if( user==@user_group.owner ||
        @user_group.users.include?(user))
      add_error("user is already a member of this group")
      return self
    end
    # ok, this user is new to the group, add them
    @user_group.users << user
    set_notice("added user to group")
    self
  end
end
