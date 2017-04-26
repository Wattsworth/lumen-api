# frozen_string_literal: true

# a column in a stream, this is the lowest element
# in the db hierarchy and contains actual data
class DbElement < ApplicationRecord
  belongs_to :db_stream

  validates :name, presence: true
  validates :name, uniqueness: { scope: :db_stream_id,
                                 message: ' is already used in this stream' }

  validates :scale_factor, presence: true, numericality: true
  validates :scale_factor, presence: true, numericality: true
  validates :default_min, allow_nil: true, numericality: true
  validates :default_max, allow_nil: true, numericality: true
  TYPES = %w(discrete continuous event)
  validates :display_type, :inclusion => {:in => TYPES}

  # force set any validated params to acceptable
  # default values this allows us to process corrupt databases
  def use_default_attributes
    self.name = "element#{column}"
    self.units = ''
    self.default_min = nil
    self.default_max = nil
    self.scale_factor = 1.0
    self.offset = 0.0
    self.display_type = 'continuous'
  end

  def name_path
    "#{db_stream.name_path}/#{self.name}"
  end

  def self.json_keys
    [:id, :db_stream_id, :name, :units, :column, :default_max,
     :default_min, :scale_factor, :offset, :plottable, :display_type]
  end
end
