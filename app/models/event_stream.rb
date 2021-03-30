# A file in the database, contains one or more Streams
class EventStream < ApplicationRecord
  belongs_to :db_folder
  belongs_to :db

  validates :name, presence: true
  validates :name, uniqueness: { scope: :db_folder_id,
                                 message: ' is already used in this folder'}


  def self.defined_attributes
    [:name, :description]
  end
  def self.json_keys
    [:id, :name, :description, :path, :start_time,
     :end_time, :size_on_disk, :total_rows, :total_time]
  end
end