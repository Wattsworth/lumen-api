class RemoveIntFromDbDecimations < ActiveRecord::Migration
  def change
    remove_column :db_decimations, :int
  end
end
