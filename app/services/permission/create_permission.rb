# frozen_string_literal: true

# Handles changing DbStream attributes
class CreatePermission
  include ServiceStatus
  attr_reader :permission

  def run(nilm, role, type, target_id)
    # create [role] perimssion on [nilm] for
    # the user or group specified
    # [type]: user|group
    # [target_id]: user_id or user_group_id value
    #
    @permission = Permission.create(nilm: nilm, role: role)
    begin
      case type
      when "user"
        if(nilm.permissions.find_by_user_id(target_id))
          add_error("user already has permissions on this nilm")
          return self
        end
        @permission.user = User.find(target_id)
      when "group"
        @permission.user_group = UserGroup.find(target_id)
        if(nilm.permissions.find_by_user_group_id(target_id))
          add_error("group already has permissions on this nilm")
          return self
        end
      else
        add_error("invalid type")
        return self
      end
    rescue ActiveRecord::RecordNotFound
      add_error("target does not exist")
      return self
    end
    unless @permission.save
      add_errors(@permission.errors.full_messages)
      return self
    end
    set_notice("Created permission")
    self
  end
end
