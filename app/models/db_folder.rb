# frozen_string_literal: true

# a folder in the database, may contain one or more DbFiles as files
# and one or more DbFolders as subfolders
class DbFolder < ActiveRecord::Base
  belongs_to :parent, class_name: 'DbFolder'
  has_many :subfolders, class_name: 'DbFolder', foreign_key: 'parent_id'
  has_many :db_files

  def defined_attributes
    [:name, :description, :hidden]
  end

  def insert_file(file:)
    # add the file to this folder
    file.db_folder = self
    # verify that the file can be here
    return false unless file.valid?
    true
  end

  def as_json(_options = {})
    folder = super(except: [:created_at, :updated_at])
    folder[:subfolders] = subfolders.map(&:as_json)
    folder[:files] = db_files.map(&:as_json)
    folder
  end
end
