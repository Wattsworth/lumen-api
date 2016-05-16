# A file in the database, contains one or more Streams
class DbFile < ActiveRecord::Base
  belongs_to :db_folder
  has_many :streams
end
