# frozen_string_literal: true

# NILM object
class Nilm < ApplicationRecord

  #---Associations-----
  has_one :db, dependent: :destroy
  has_many :permissions, dependent: :destroy #viewer, owner, admin
  has_many :users, through: :permissions
  has_many :user_groups, through: :permissions
  has_many :data_views_nilms
  has_many :data_views, through: :data_views_nilms
  has_many :joule_modules, dependent: :destroy
  #---Validations-----
  validates :name, presence: true, uniqueness: true
  validates :url, presence: true, uniqueness: true

  #---Callbacks------
  before_destroy do |record|
    DataView.destroy(record.data_views.pluck(:id))
  end

  def self.json_keys
    [:id, :name, :description, :url]
  end

end
