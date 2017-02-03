class AddAvailableToDb < ActiveRecord::Migration[5.0]
  def change
    add_column :dbs, :available, :boolean
  end
end
