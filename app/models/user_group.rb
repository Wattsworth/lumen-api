# Logical groups of users for bulk permission assignment. The group has a single
# +owner+ who alone can add and remove members. Permissions inherited through a group
# assignment are merged with individually assigned permissions with the highest permission
# level taking precedence. That is you can't be demoted by being assigned to a group.
#
# ===Accessible Attributes
# * +attr+ - descrip
#
# ===Protected Attributes
# * +name+ - friendly name
# * +description+ - description of the group
# * +owner+ - User object
#
class UserGroup < ApplicationRecord
  #---Associations----
  has_and_belongs_to_many :users
  belongs_to :owner, class_name: "User"
  has_many :permissions, dependent: :destroy
  has_many :nilms, through: :permissions

  #---Validations-----
  validates :name, :presence => true, :uniqueness => true
  validates :owner_id, :presence => true


  # ----------------------------------------
  # :section: Class Methods
  # ----------------------------------------
  def self.json_keys #public attributes
    [:id, :name, :description]
  end

end
