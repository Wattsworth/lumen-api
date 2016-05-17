# frozen_string_literal: true

# A file in the database, contains one or more Streams
class DbFile < ActiveRecord::Base
  belongs_to :db_folder
  has_many :db_streams, dependent: :destroy

  def remove(db_service:)
    db_service.remove_file(path)
    destroy
  end
end
