class AddPlottableToDbStream < ActiveRecord::Migration
  def change
    add_column :db_streams, :plottable, :boolean
    add_column :db_streams, :discrete, :boolean
  end
end
