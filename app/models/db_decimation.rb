# frozen_string_literal: true

# Decimation level of a file
class DbDecimation < ActiveRecord::Base
  belongs_to :db_file
end
