class AddInvitationUrlToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :invitation_url, :string
  end
end
