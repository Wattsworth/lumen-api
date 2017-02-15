class Permission < ApplicationRecord
  #---Associations----
  belongs_to :user
  belongs_to :user_group
  belongs_to :nilm
end
