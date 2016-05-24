# frozen_string_literal: true

# A file in the database, contains one or more Streams
class DbFile < ActiveRecord::Base
  belongs_to :db_folder
  has_many :db_streams, dependent: :destroy
  has_many :db_decimations, dependent: :destroy
  accepts_nested_attributes_for :db_streams

  def remove(db_service:)
    db_service.remove_file(path)
    destroy
  end

  def as_json(_options = {})
    super(except: [:created_at, :updated_at])
  end
end
