class JouleModule < ApplicationRecord
  belongs_to :nilm
  has_many :joule_pipes
end
