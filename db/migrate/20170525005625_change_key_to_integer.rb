class ChangeKeyToInteger < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :home_data_view_id, :integer
  end
end
