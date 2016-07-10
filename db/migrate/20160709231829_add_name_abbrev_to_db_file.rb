class AddNameAbbrevToDbFile < ActiveRecord::Migration
  def change
    add_column :db_files, :name_abbrev, :string
  end
end
