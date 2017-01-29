class AddFieldsToDb < ActiveRecord::Migration[5.0]
  def change
    add_column :dbs, :size_total, :integer, :limit => 8
    add_column :dbs, :size_db, :integer, :limit => 8
    add_column :dbs, :size_other, :integer, :limit => 8
    add_column :dbs, :version, :string
    add_column :dbs, :max_points_per_plot, :integer, :default => 3600
  end
end
