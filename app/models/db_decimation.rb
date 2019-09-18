# frozen_string_literal: true

# Decimation level of a file
class DbDecimation < ApplicationRecord
  belongs_to :db_stream

end
