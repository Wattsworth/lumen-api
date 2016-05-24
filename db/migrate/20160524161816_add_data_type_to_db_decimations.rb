class AddDataTypeToDbDecimations < ActiveRecord::Migration
  def change
    add_column :db_decimations, :data_type, :string
  end
end
