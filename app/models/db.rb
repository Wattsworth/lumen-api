# frozen_string_literal: true

# Database object
class Db < ApplicationRecord

  #---Associations----
  belongs_to :root_folder,
             foreign_key: 'db_folder_id',
             class_name: 'DbFolder',
             dependent: :destroy
  belongs_to :nilm

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

  def self.json_keys
    [:id, :url, :size_total, :size_db, :available,
     :size_other, :version, :max_points_per_plot]
  end
end
