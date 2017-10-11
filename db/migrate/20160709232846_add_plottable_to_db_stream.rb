class AddPlottableToDbStream < ActiveRecord::Migration[5.0]
  def change
    add_column :db_streams, :plottable, :boolean
    add_column :db_streams, :discrete, :boolean
  end
end
