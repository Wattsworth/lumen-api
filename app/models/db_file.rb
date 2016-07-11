# frozen_string_literal: true

# A file in the database, contains one or more Streams
class DbFile < ActiveRecord::Base
  belongs_to :db_folder
  has_many :db_streams, dependent: :destroy
  has_many :db_decimations, dependent: :destroy


  def defined_attributes
    [:name, :name_abbrev, :description, :hidden]
  end

  def remove(db_service:)
    db_service.remove_file(path)
    destroy
  end

  def as_json(_options = {})
    file = super(except: [:created_at, :updated_at])
    file[:streams] = db_streams.map(&:as_json)
    file[:decimations] = db_decimations.map(&:as_json)
    file
  end
end
