class Permission < ApplicationRecord
  #---Associations----
  belongs_to :user
  belongs_to :user_group
  belongs_to :nilm

  #---Validations---
  ROLES = %w(admin owner viewer)
  validates :role, :inclusion => {:in => ROLES}
  validate :user_xor_group

  def user_xor_group
    unless user.blank? ^ user_group.blank?
      errors.add(:base, "specify a user or group not both")
    end
  end

  def target_name
    return self.user.name if self.user_id?
    return self.user_group.name if self.user_group_id?

    "[no target set]"

  end

  def target_type
    if self.user_id?
      return 'user'
    elsif self.user_group_id?
      return 'group'
    else
      return 'unknown'
    end
  end

  def self.json_keys
    [:id, :nilm_id, :role]
  end

end
