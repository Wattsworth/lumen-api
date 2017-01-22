# frozen_string_literal: true

# a column in a stream, this is the lowest element
# in the db hierarchy and contains actual data
class DbElement < ApplicationRecord
  belongs_to :db_stream

  validates :name, presence: true
  validates :name, uniqueness: { scope: :db_stream_id,
    message: ' is already used in this folder'}


  def as_json(_options = {})
    super(except: [:created_at, :updated_at])
  end
end
