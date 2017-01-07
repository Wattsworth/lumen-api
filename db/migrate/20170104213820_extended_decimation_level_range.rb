# frozen_string_literal: true
class ExtendedDecimationLevelRange < ActiveRecord::Migration
  def change
    change_column :db_decimations, :level, :integer, limit: 8
  end
end
