# frozen_string_literal: true

# validate that the file has the appropriate number
# of streams given the format string
class DbDataTypeValidator < ActiveModel::Validator
  def validate(record)
    # streams might not be built yet
    return if record.db_elements.count.zero?
    # TODO: check for valid format strings (float32, uint8, etc)
    unless record.db_elements.count == record.column_count
      record.errors[:base] << "must have #{record.column_count} \
        elements for format #{record.data_type}"
    end
  end
end

# A file in the database, contains one or more Streams
class DbStream < ApplicationRecord
  belongs_to :db_folder
  belongs_to :db
  has_many :db_elements, dependent: :destroy, autosave: true
  has_many :db_decimations, dependent: :destroy
  accepts_nested_attributes_for :db_elements

  validates :name, presence: true
  validates :name, uniqueness: { scope: :db_folder_id,
    message: ' is already used in this folder'}

  validates_with DbDataTypeValidator

  def defined_attributes
     [:name, :name_abbrev, :description, :hidden]
  end

  def name_path
    "#{db_folder.name_path}/#{self.name}"
  end

  def remove(db_service:)
    db_service.remove_file(path)
    destroy
  end

  def data_format
    /^(\w*)_\d*$/.match(data_type)[1]
  end

  def column_count
    /^\w*_(\d*)$/.match(data_type)[1].to_i
  end

  # force set any validated params to acceptable
  # default values this allows us to process corrupt databases
  def use_default_attributes
    self.name = self.path
    self.description = ''
  end

  def self.json_keys
    [:id, :name, :description, :path, :start_time,
     :end_time, :size_on_disk, :total_rows, :total_time,
     :data_type, :name_abbrev, :delete_locked, :hidden]
  end

end
