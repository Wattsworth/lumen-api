class RemoveIntFromDbDecimations < ActiveRecord::Migration[5.0]
  def change
    # fixed in 20160524023257_create_db_decimations
    # remove_column :db_decimations, :int
  end
end
