class JouleModule < ApplicationRecord
  belongs_to :nilm
  has_many :joule_pipes, dependent: :destroy

  # attributes accepted from the Joule json response
  def self.defined_attributes
    [:name, :description, :web_interface, :exec_cmd,
     :status, :pid, :joule_id]
  end
  # attributes sent to the client
  def self.json_keys
    [:id, :name, :description, :web_interface, :exec_cmd,
     :status, :pid, :joule_id]
  end
end
