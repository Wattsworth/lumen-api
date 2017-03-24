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
    message: ' is already used in this folder'}, unless: :root_folder?

  #:section: Utility Methods

  def root_folder?
    self.parent == nil
  end

  def name_path
    return "" if root_folder?
    return "#{parent.name_path}/#{self.name}"
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

  # force set any validated params to acceptable
  # default values this allows us to process corrupt databases
  def use_default_attributes
    self.name = self.path
    self.description = ''
  end

  def self.json_keys
    [:id, :name, :description, :path, :hidden,
     :start_time, :end_time, :size_on_disk]
  end
end
