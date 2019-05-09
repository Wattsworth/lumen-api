# frozen_string_literal: true

# NILM object
class NilmAuthKey < ApplicationRecord

  #---Associations-----
  belongs_to :user

  after_initialize do |auth_key|
    auth_key.key ||= SecureRandom.hex(3).upcase
  end

end
