# frozen_string_literal: true

# a stream in the database, this is the lowest element
# in the db hierarchy and contains actual data
class DbStream < ActiveRecord::Base
  belongs_to :db_file
end
