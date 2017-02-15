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
  has_many :permissions
  has_many :nilms, through: :permissions

  #---Validations-----
  validates :name, :presence => true, :uniqueness => true
  validates :description, :presence => true
  validates :owner_id, :presence => true


  #---------------
  #:section: Utility Methods
  #---------------

  # Returns a json model of the UserGroup.
  # ===attributes
  # * +options+: hash, pass <tt>{}</tt> for no options, or <tt>{:include_members=>true}</tt>
  #
  # ===examples
  #
  #  #Just the group
  #  user_group.as_json({}) =
  #  {"name"        => "Lab Group",
  #   "description" => "Users working on NILM in the lab",
  #   "id"          => 3}
  #
  #  #Include the members
  #  user_group.as_json({:include_members=>true}) =
  #  {"name"        => "Lab Group",
  #   "description" => "Users working on NILM in the lab",
  #   "id"          => 3}
  #   :members      => [
  #       {"first_name" => "John",
  #        "last_name"  => "Ledner",
  #        "id"         => 3,
  #        :confirmed   => true,
  #        }, ... ]
  #   }
  def as_json(options)
     group = super(only: [:name, :description, :id])
     if(options[:include_members])
       group[:members] = self.users.as_json(:abbreviated=>true)
     end
     return group
  end
end
