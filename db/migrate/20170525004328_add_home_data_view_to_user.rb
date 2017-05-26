class AddHomeDataViewToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :home_data_view_id, :number
  end
end
