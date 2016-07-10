# frozen_string_literal: true

# Wrapper around NilmDB HTTP service
class DbAdapter
  include HTTParty

  def initialize(url)
    @url = url
  end

  def schema # rubocop:disable Metrics/MethodLength
    # GET extended info stream list
    dump = self.class.get("#{@url}/stream/list?extended=1")
    dump.parsed_response.map do |entry|
      # TODO: implement global metadata dump, because this is sloooow
      # GET metadata for the stream
      dump = self.class.get("#{@url}/stream/get_metadata?path=#{entry[0]}")
      metadata = JSON.parse(dump.parsed_response['config_key__'] || '{}')
      # The streams are not pure attributes, pull them out
      streams = metadata["streams"] || {}
      # Add plain-text metadata keys (retrofit for *info streams which keep
      # attributes in seperate metadata tags
      metadata.merge!(dump.parsed_response.slice("delete_locked",
                                                "description",
                                                "hidden",
                                                "name"))
      # Create the schema:
      # 3 elements: path, attributes, streams
      { path:       entry[0],
        attributes: {
          data_type:  entry[1],
          start_time: entry[2] || 0,
          end_time:   entry[3] || 0,
          total_rows: entry[4],
          total_time: entry[5]
        }.merge(metadata.except("streams")),
        streams: streams
      }
    end
  end
end
