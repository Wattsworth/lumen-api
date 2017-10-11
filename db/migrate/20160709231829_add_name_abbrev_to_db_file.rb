class AddNameAbbrevToDbFile < ActiveRecord::Migration[5.0]
  def change
    add_column :db_files, :name_abbrev, :string
  end
end
