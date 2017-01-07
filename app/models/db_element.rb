# frozen_string_literal: true

# a column in a stream, this is the lowest element
# in the db hierarchy and contains actual data
class DbElement < ActiveRecord::Base
  belongs_to :db_stream

  def as_json(_options = {})
    super(except: [:created_at, :updated_at])
  end
end
