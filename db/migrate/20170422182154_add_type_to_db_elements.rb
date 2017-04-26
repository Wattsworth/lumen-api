class AddTypeToDbElements < ActiveRecord::Migration[5.0]
  def change
    add_column :db_elements, :type, :string
    remove_column :db_elements, :discrete
  end
end
