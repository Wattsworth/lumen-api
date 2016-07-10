class RenameScaleToScaleFactorInDbStreams < ActiveRecord::Migration
  def change
    rename_column :db_streams, :scale, :scale_factor
  end
end
