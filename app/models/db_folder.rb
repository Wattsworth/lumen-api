# frozen_string_literal: true

# a folder in the database, may contain one or more DbFiles as files
# and one or more DbFolders as subfolders
class DbFolder < ActiveRecord::Base
  has_many :subfolders
  has_many :files
end
