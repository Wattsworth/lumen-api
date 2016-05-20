# frozen_string_literal: true

# Wrapper around NilmDB HTTP service
class DbAdapter
  include HTTParty

  def initialize(url)
    @url = url
  end

  def schema
    dump = self.class.get("#{@url}/stream/list?extended=1")
    dump.parsed_response.map do |entry|
      { path:       entry[0],
        type:       entry[1],
        start_time: entry[2] || 0,
        end_time:   entry[3] || 0,
        total_rows: entry[4],
        total_time: entry[5] }
    end
  end
end
