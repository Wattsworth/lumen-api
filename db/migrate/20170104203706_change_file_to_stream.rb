# frozen_string_literal: true
class ChangeFileToStream < ActiveRecord::Migration
  def change
    rename_table :db_streams, :db_elements
    rename_table :db_files, :db_streams
  end
end
