class JouleModule < ApplicationRecord
  belongs_to :nilm
  has_many :joule_pipes, dependent: :destroy

  def self.json_keys
    [:name, :description, :web_interface, :exec_cmd,
     :status, :pid]
  end
end
