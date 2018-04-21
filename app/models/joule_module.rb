class JouleModule < ApplicationRecord
  belongs_to :nilm
  has_many :joule_pipes, dependent: :destroy

  # attributes accepted from the Joule json response
  def self.joule_keys
    [:name, :description, :web_interface, :exec_cmd,
     :status, :pid]
  end
  # attributes sent to the client
  def self.json_keys
    [:id, :name, :description, :web_interface, :exec_cmd,
     :status, :pid]
  end
end
