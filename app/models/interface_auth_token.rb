class InterfaceAuthToken < ApplicationRecord
  belongs_to :joule_module
  belongs_to :user

  after_initialize do |auth_token|
    auth_token.value ||= SecureRandom.hex
  end

  def url
    "http://localhost:3000/interfaces/#{joule_module.id}/authenticate?token=#{value}"
  end
end
