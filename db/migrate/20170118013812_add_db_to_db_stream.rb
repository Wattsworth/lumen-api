class AddDbToDbStream < ActiveRecord::Migration
  def change
    add_column :db_streams, :db_id, :integer
  end
end
