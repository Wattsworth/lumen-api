class CreateInterfaceAuthTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :interface_auth_tokens do |t|
      t.belongs_to :user, index: true
      t.belongs_to :joule_module, index: true
      t.string :value
      t.datetime :expiration
      t.timestamps
    end
  end
end
