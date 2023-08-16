class AddActiveFieldToDbStream < ActiveRecord::Migration[7.0]
  def change
    add_column :db_streams, :active, :boolean, default: false
  end
end
