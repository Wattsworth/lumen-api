class AddDbToDbStream < ActiveRecord::Migration[5.0]
  def change
    add_column :db_streams, :db_id, :integer
  end
end
