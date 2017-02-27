# frozen_string_literal: true

# Handles removing users from a group
class RemoveGroupMember
  include ServiceStatus
  attr_reader :user_group

  def run(user_group, user_id)
    # remove user specified by [user_id] from the group
    @user_group = user_group
    user = User.find_by_id(user_id)
    if user.nil?
      add_error("invalid user_id")
      return self
    end
    if( user==@user_group.owner )
      add_error("cannot remove the group owner")
      return self
    end
    if( not @user_group.users.include?(user))
      add_error("user is not a member of this group")
      return self
    end
    # ok, this user is a member of the group, remove them
    @user_group.users.delete(user)
    set_notice("removed user from group")
    self
  end
end
