# frozen_string_literal: true

# NILM object
class Nilm < ActiveRecord::Base
  has_one :db

  def as_json(_options = {})
    nilm = super(except: [:created_at, :updated_at])
    nilm
  end
end
