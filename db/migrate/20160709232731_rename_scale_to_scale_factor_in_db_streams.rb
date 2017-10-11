class RenameScaleToScaleFactorInDbStreams < ActiveRecord::Migration[5.0]
  def change
    rename_column :db_streams, :scale, :scale_factor
  end
end
