# frozen_string_literal: true

# Wrapper around NilmDB HTTP service
class DbAdapter
  include HTTParty

  def initialize(url)
    @url = url
  end

  def schema
    # GET extended info stream list
    dump = self.class.get("#{@url}/stream/list?extended=1")
    dump.parsed_response.map do |entry|
      metadata = if entry[0].match(UpdateStream.decimation_tag).nil?
                   __get_metadata(entry[0])
                 else
                   {} # decimation entry, no need to pull metadata
                 end
      # The streams are not pure attributes, pull them out
      elements = metadata.delete(:streams) || []
      elements.each(&:symbolize_keys!)
      # Create the schema:
      # 3 elements: path, attributes, elements
      {
        path:       entry[0],
        attributes: {
          data_type:  entry[1],
          start_time: entry[2] || 0,
          end_time:   entry[3] || 0,
          total_rows: entry[4],
          total_time: entry[5]
        }.merge(metadata),
        elements: elements
      }
    end
  end

  # retrieve metadata for a particular stream
  def __get_metadata(path)
    dump = self.class.get("#{@url}/stream/get_metadata?path=#{path}")
    metadata = JSON.parse(dump.parsed_response['config_key__'] || '{}')
    # Add plain-text metadata keys (retrofit for *info streams which keep
    # attributes in seperate metadata tags
    metadata.merge!(dump.parsed_response)
    __sanitize_metadata(metadata)
  end

  # make sure all the keys are valid parameters
  def __sanitize_metadata(metadata)
    metadata.slice!('delete_locked', 'description', 'hidden', 'name',
                    'streams')
    if(metadata['streams'] != nil)
      # sanitize 'streams' (elements) parameters
      element_attrs = DbElement.attribute_names.map(&:to_sym)
      metadata['streams'].map! do |element|
        element.symbolize_keys
          .slice(*element_attrs)
      end
    end
    metadata.symbolize_keys
  end
end
