class User < ActiveRecord::Base
  #---Attributes------
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable, :omniauthable
  include DeviseTokenAuth::Concerns::User

  #---Associations----
  has_many :permissions
  has_many :nilms, through: :permissions
  has_and_belongs_to_many :user_groups

  #---Validations-----
  validates :first_name, :last_name, :email, :presence => true
  validates :email, :uniqueness => true
  validates :password, :confirmation => true

  # ----------------------------------------
  # :section: Permission Checkers
  # ----------------------------------------

  # Returns a dict of nilms this user can access
  # nilms are grouped by role (+admin+,+owner+,+viewer+). Nilms are unique
  # and assigned to the highest permission bin. If a user has direct permissions as +owner+ on
  # an nilm and also +viewer+ permissions through a group, the nilm will be in
  # the +owner+ array only.
  #
  # ==== Example
  #   nilms = {
  #     :admin =>  [x, y, z],
  #     :owner =>  [m, n],
  #     :viewer => []
  #   }
  #
  def retrieve_nilms_by_permission
    #return Nilm's categorized by permission level (viewer, admin, owner)
    nilms = {}
    roles=[:admin,:owner,:viewer]
    #only account for each nilm once- use the highest permission level
    allowed_nilms = []
    roles.each do |role|
      #first get NILM's explicitly related to this user
      user_nilms = self.nilms.where(permissions:{role: role})
      allowed_nilms+= user_nilms.pluck(:id)

      #add NILM's related through a user_group
      User.joins(:user_groups, :permissions, :nilms)
      user_groups = self.user_groups
      group_nilms = Nilm.joins(permissions: :user_group).where(permissions:{role: role}).
         where(user_groups: {id: user_groups.pluck(:id)})
      if(not allowed_nilms.empty?)
        group_nilms = group_nilms.where("nilms.id NOT IN (?)", allowed_nilms)
      end
      allowed_nilms += group_nilms.pluck(:id)
      nilms[role] = user_nilms + group_nilms
    end
    return nilms
  end

  #returns true if the user has +admin+ privileges either directly or through a group
  def admins_nilm?(nilm)
    return self.has_permission("admin",nilm)
  end

  #returns true if the user has <em>at least</em> +owner+ privileges either directly or through a group
  def owns_nilm?(nilm)
    return self.has_permission(["admin","owner"],nilm)
  end


  #returns true if the user has <em> at least</em> +viewer+ privileges either directly or through a group
  def views_nilm?(nilm)
    return self.has_permission(["admin","owner","viewer"],nilm)
  end

  protected


    # :category: Permission Checkers
    #
    # checks if the user has either direct or group permissions of one or more specified +roles+
    # on a specified +nilm+
    #
    # ===attributes
    # * +roles+: array of roles [+admin+,+owner+,+viewer+]
    # * +nilm+: nilm object to check
    #
    def has_permission(roles,nilm)
      #check if user has [roles] on the nilm directly
      answer = self.nilms.where(permissions:{role: roles}, id: nilm.id).exists?
      if(answer == false) #if not, check if he has [roles] through a group
        answer = Nilm.joins(permissions: :user_group).
              where(permissions:{role: roles}).
              where(user_groups: {id: self.user_groups.pluck(:id)}).
              where(nilms: {id: nilm.id}).exists?
      end
      return answer
    end
end
