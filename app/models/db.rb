# frozen_string_literal: true

# Database object
class Db < ActiveRecord::Base
  belongs_to :root_folder, foreign_key: 'db_folder_id', class_name: 'DbFolder'
end
