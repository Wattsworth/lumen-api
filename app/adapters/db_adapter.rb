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
      metadata = __get_metadata(entry[0])

      # The streams are not pure attributes, pull them out
      streams = metadata.delete(:streams) || {}

      # Create the schema:
      # 3 elements: path, attributes, streams
      { path:       entry[0],
        attributes: {
          data_type:  entry[1],
          start_time: entry[2] || 0,
          end_time:   entry[3] || 0,
          total_rows: entry[4],
          total_time: entry[5]
        }.merge(metadata),
        streams: streams
      }
    end
  end

  # retrieve metadata for a particular stream
  def __get_metadata(path)
    dump = self.class.get("#{@url}/stream/get_metadata?path=#{path}")
    metadata = JSON.parse(dump.parsed_response['config_key__'] || '{}')
    # Add plain-text metadata keys (retrofit for *info streams which keep
    # attributes in seperate metadata tags
    metadata.merge!(dump.parsed_response.slice('delete_locked',
                                               'description',
                                               'hidden',
                                               'name'))
    metadata.symbolize_keys
  end
end
