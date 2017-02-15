class CreatePermissions < ActiveRecord::Migration[5.0]
  def change
    create_table :permissions do |t|
      t.integer  "nilm_id"
      t.integer  "user_id"
      t.string "role"
      t.timestamps
    end
  end
end
