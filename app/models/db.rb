# frozen_string_literal: true

# Database object
class Db < ApplicationRecord

  #---Associations----
  belongs_to :root_folder,
             foreign_key: 'db_folder_id',
             class_name: 'DbFolder',
             dependent: :destroy
  belongs_to :nilm
  has_many :db_streams #flat map of all streams in database
  has_many :db_folders
  has_many :event_streams
  #---Validations
  validates :max_points_per_plot, numericality: { only_integer: true }

  def url
    # return a custom URL if set
    return super unless super.nil? || super.empty?
    # no default URL if no parent NILM available
    return '--error, no parent NILM--' if nilm.nil?
    # return the default URL
    nilm.url
  end

end
