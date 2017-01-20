# frozen_string_literal: true

# a folder in the database, may contain one or more DbFiles as files
# and one or more DbFolders as subfolders
class DbFolder < ActiveRecord::Base
  belongs_to :parent, class_name: 'DbFolder'
  belongs_to :db

  has_many :subfolders,
           class_name: 'DbFolder',
           foreign_key: 'parent_id',
           dependent: :destroy

  has_many :db_streams,
           dependent: :destroy

  validates_presence_of :name
  validate :name_is_unique_in_group

  #:section: Utility Methods

  #vaildator to ensure the name is unique to the parent.
  def name_is_unique_in_group
    self.parent.subfolders.each do |folder|
      if((folder.name == self.name) and (folder.id != self.id ))
        self.errors.add(:name, "[#{self.name}] is already used")
      end
    end
  end


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
