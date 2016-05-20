# frozen_string_literal: true

# Wrapper around NilmDB HTTP service
class DbAdapter
  include HTTParty

  def initialize(url)
    @url = url
  end

  def schema
    x = self.class.get("#{@url}/stream/list")
    byebug
  end
end
