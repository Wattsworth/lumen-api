class RemoveIntFromDbDecimations < ActiveRecord::Migration[5.0]
  def change
    remove_column :db_decimations, :int
  end
end
