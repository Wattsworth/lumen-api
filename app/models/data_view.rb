class DataView < ApplicationRecord

  #---Associations----
  has_many :data_views_nilms
  has_many :nilms, through: :data_views_nilms, dependent: :destroy

  belongs_to :owner,
              class_name: 'User',
              foreign_key: 'user_id'

  #---Validations-----
  validates :name, :presence => true

  #return all DataViews that can be loaded by this user
  def self.find_viewable(user)
    #make a list of allowed nilms
    r = user.retrieve_nilms_by_permission
    nilms = r[:admin]+r[:owner]+r[:viewer]
    #find all DataViewsNilms that are not allowed
    prohibited = DataViewsNilm.where.not(nilm_id: nilms.pluck(:id))
    #find the *other* DataViewsNilms (allowed)
    allowed_ids = DataViewsNilm.where.not(id: prohibited.pluck(:id))
      .pluck(:data_view_id).uniq
    DataView.find(allowed_ids)
  end

  def self.json_keys
    [:id, :name, :description, :image, :redux_json]
  end

end
