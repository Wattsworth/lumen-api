class InterfaceAuthToken < ApplicationRecord
  belongs_to :joule_module
  belongs_to :user

  after_initialize do |auth_token|
    auth_token.value ||= SecureRandom.hex
  end
end
