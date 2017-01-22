# frozen_string_literal: true

# Decimation level of a file
class DbDecimation < ApplicationRecord
  belongs_to :db_stream

  def as_json(_options = {})
    super(except: [:created_at, :updated_at])
  end
end
