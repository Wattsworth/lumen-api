# frozen_string_literal: true

# Database object
class Db < ApplicationRecord
  belongs_to :root_folder,
             foreign_key: 'db_folder_id',
             class_name: 'DbFolder',
             dependent: :destroy
  belongs_to :nilm

  def url
    # return a custom URL if set
    return super unless super.nil? || super.empty?
    # no default URL if no parent NILM available
    return '--error, no parent NILM--' if nilm.nil?
    # return the default URL"
    "#{nilm.url}/nilmdb"
  end

  def as_json(options = {})
    db = super(except: [:created_at, :updated_at])
    db[:contents] = root_folder.as_json({shallow: false})
    db
  end
end
