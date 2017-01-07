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
class DbStream < ActiveRecord::Base
  belongs_to :db_folder
  has_many :db_elements, dependent: :destroy
  has_many :db_decimations, dependent: :destroy

  validates_with DbDataTypeValidator

  def defined_attributes
    [:name, :name_abbrev, :description, :hidden]
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

  def as_json(_options = {})
    stream = super(except: [:created_at, :updated_at])
    stream[:elements] = db_elements.map(&:as_json)
    stream[:decimations] = db_decimations.map(&:as_json)
    stream
  end
end
