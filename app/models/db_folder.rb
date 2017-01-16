# frozen_string_literal: true

# a folder in the database, may contain one or more DbFiles as files
# and one or more DbFolders as subfolders
class DbFolder < ActiveRecord::Base
  belongs_to :parent, class_name: 'DbFolder'
  has_many :subfolders,
           class_name: 'DbFolder',
           foreign_key: 'parent_id',
           dependent: :destroy

  has_many :db_streams,
           dependent: :destroy

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
