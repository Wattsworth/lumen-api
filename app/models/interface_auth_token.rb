class InterfaceAuthToken < ApplicationRecord
  belongs_to :data_app
  belongs_to :user

  after_initialize do |auth_token|
    auth_token.value ||= SecureRandom.hex
  end
end
