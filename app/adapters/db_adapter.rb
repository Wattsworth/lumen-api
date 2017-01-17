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

  def set_folder_metadata(db_folder)
    params = { path: "#{db_folder.path}/info",
               data: __build_folder_metadata(db_folder) }.to_json
    response = self.class.post("#{@url}/stream/update_metadata",
                               body: params,
                               headers: { 'Content-Type' => 'application/json' })
    if response.code != 200
      Rails.logger.warn (
        "#{@url}: update_metadata(#{db_folder.path})"+
        " => #{response.code}:#{response.body}"
      )
      return { error: true, msg: "error updating #{db_folder.path} metadata" }
    end
    { error: false, msg: 'success' }
  end

  # convert folder attributes to __config_key json
  def __build_folder_metadata(db_folder)
    attribs = db_folder.attributes
                       .slice('name', 'description', 'hidden')
                       .to_json
    { config_key__: attribs }.to_json
end

  # retrieve metadata for a particular stream
  def __get_metadata(path)
    dump = self.class.get("#{@url}/stream/get_metadata?path=#{path}")
    # find legacy parameters in raw metadata
    metadata = dump.parsed_response.except('config_key__')
    # parse values from config_key entry if it exists
    config_key = JSON.parse(dump.parsed_response['config_key__'] || '{}')
    # merge legacy data with config_key values
    metadata.merge!(config_key)
    # make sure nothing bad got in (eg extraneous metadata keys)
    __sanitize_metadata(metadata)
  end

  # make sure all the keys are valid parameters
  # this function does not know the difference between folders and streams
  # this *should* be ok as long as nobody tinkers with the config_key__ entries
  def __sanitize_metadata(metadata)
    metadata.slice!('delete_locked', 'description', 'hidden',
                    'name', 'name_abbrev', 'streams')
    unless metadata['streams'].nil?
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
