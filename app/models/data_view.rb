class DataView < ApplicationRecord

  #---Associations----
  has_many :data_views_nilms
  has_many :nilms, through: :data_views_nilms, dependent: :destroy

  belongs_to :owner,
              class_name: 'User',
              foreign_key: 'user_id'

  #---Validations-----
  validates :name, :presence => true
  TYPES = %w(public private hidden)
  validates :visibility, :inclusion => {:in => TYPES}


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
    #find all visible data views
    visible_ids = DataView.where(owner: user).
      or(DataView.where(visibility: 'public')).
      pluck(:id)
    #permitted views must be both visible and allowed
    DataView.where(id: allowed_ids&visible_ids)
  end

  def self.json_keys
    [:id, :name, :description, :image, :redux_json, :visibility]
  end

end
