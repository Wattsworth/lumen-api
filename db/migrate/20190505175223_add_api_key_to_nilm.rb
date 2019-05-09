class AddApiKeyToNilm < ActiveRecord::Migration[5.2]
  def change
    add_column :nilms, :key, :string
    create_table "nilm_auth_keys", :force => true do |t|
      t.integer  "user_id"
      t.string   "key"
      t.timestamps
    end
  end
end
