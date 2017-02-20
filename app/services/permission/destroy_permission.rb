# frozen_string_literal: true

# Handles permission removal
class DestroyPermission
  include ServiceStatus

  def run(nilm, requester, id)
    # remove permission [id] from nilm
    # do not allow [requester] to remove his permission
    @permission = nilm.permissions.find_by_id(id)
    if @permission.nil?
      add_error 'invalid permission id'
      return self
    elsif(@permission.user == requester)
      add_error 'cannot remove your own permission'
      return self
    else
      @permission.destroy
      add_notice 'removed permission'
      return self
    end
  end
end
