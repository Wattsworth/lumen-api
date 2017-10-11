class AddDataTypeToDbDecimations < ActiveRecord::Migration[5.0]
  def change
    add_column :db_decimations, :data_type, :string
  end
end
