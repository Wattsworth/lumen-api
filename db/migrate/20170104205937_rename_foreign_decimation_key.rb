# frozen_string_literal: true
class RenameForeignDecimationKey < ActiveRecord::Migration
  def change
    rename_column :db_decimations, :db_file_id, :db_stream_id
  end
end
