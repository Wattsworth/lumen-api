# frozen_string_literal: true

# NILM object
class Nilm < ApplicationRecord

  #---Associations-----
  has_one :db, dependent: :destroy
  has_many :permissions, dependent: :destroy #viewer, owner, admin
  has_many :users, through: :permissions
  has_many :user_groups, through: :permissions

  #---Validations-----
  validates :name, presence: true


  def self.json_keys
    [:id, :name, :description, :url]
  end

end
