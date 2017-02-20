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
    if self.user_id?
      return self.user.name
    elsif self.user_group_id?
      return self.user_group.name
    else
      return "[no target set]"
    end
  end

  def self.json_keys
    [:id, :nilm_id, :role]
  end

end
