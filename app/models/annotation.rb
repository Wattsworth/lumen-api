class Annotation

  attr_accessor :id
  attr_accessor :title
  attr_accessor :content
  attr_accessor :start_time
  attr_accessor :end_time
  attr_accessor :db_stream

  def self.json_keys
    [:id, :title, :content]
  end

end