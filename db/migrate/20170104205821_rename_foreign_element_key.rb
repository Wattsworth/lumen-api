# frozen_string_literal: true
class RenameForeignElementKey < ActiveRecord::Migration[5.0]
  def change
    rename_column :db_elements, :db_file_id, :db_stream_id
  end
end
