class FixPermissionsTable < ActiveRecord::Migration[5.0]
  def change
    rename_column :permissions, :installation_id, :nilm_id
  end
end
