class DataApp < ApplicationRecord
  belongs_to :nilm


  def url
    "#{nilm.url}/app/#{joule_id}/"
  end

end
