class ExtendSizeOnDiskType < ActiveRecord::Migration[5.0]
  def change
    change_column :db_folders, :size_on_disk, :integer, limit: 8
    change_column :db_streams, :size_on_disk, :integer, limit: 8


  end
end
