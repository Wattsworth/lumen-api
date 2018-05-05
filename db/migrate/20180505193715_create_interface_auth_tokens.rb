class CreateInterfaceAuthTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :interface_auth_tokens do |t|

      t.timestamps
    end
  end
end
