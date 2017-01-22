# frozen_string_literal: true



# a folder in the database, may contain one or more DbFiles as files
# and one or more DbFolders as subfolders
class DbFolder < ApplicationRecord
  belongs_to :parent, class_name: 'DbFolder'
  belongs_to :db

  has_many :subfolders,
           class_name: 'DbFolder',
           foreign_key: 'parent_id',
           dependent: :destroy

  has_many :db_streams,
           dependent: :destroy

  validates_presence_of :name
  # validates_with DbFolderValidator
  validates :name, uniqueness: { scope: :parent_id,
    message: ' is already used in this folder'}

  #:section: Utility Methods




  def self.defined_attributes
    [:name, :description, :hidden]
  end

  def insert_stream(stream:)
    # add the stream to this folder
    stream.db_folder = self
    # verify that the file can be here
    return false unless stream.valid?
    true
  end

  def as_json(options = {shallow: true})
    folder = super(except: [:created_at, :updated_at])
    if(options[:shallow]== false)
      folder[:subfolders] = subfolders.map(&:as_json)
      folder[:streams] = db_streams.includes(:db_elements,:db_decimations).map(&:as_json)
    end
    folder
  end
end
