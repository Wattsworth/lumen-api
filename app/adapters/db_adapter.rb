# frozen_string_literal: true

# Wrapper around NilmDB HTTP service
class DbAdapter
  include HTTParty
  default_timeout 10
  attr_reader :url

  def initialize(url)
    @url = url
  end

  def dbinfo
    begin
      resp = self.class.get("#{@url}/version")
      return nil unless resp.success?
      version = resp.parsed_response

      resp = self.class.get("#{@url}/dbinfo")
      return nil unless resp.success?
      info = resp.parsed_response
    rescue
      return nil
    end
    # if the site exists but is not a nilm...
    required_keys = %w(size other free reserved)
    unless info.respond_to?(:has_key?) &&
           required_keys.all? { |s| info.key? s }
      return nil
    end
    {
      version: version,
      size_db: info['size'],
      size_other: info['other'],
      size_total: info['size'] + info['other'] + info['free'] + info['reserved']
    }
  end

  def schema
    # GET extended info stream list
    begin
      resp = self.class.get("#{@url}/stream/list?extended=1")
      return nil unless resp.success?
    rescue
      return nil
    end
    # if the url exists but is not a nilm...
    return nil unless resp.parsed_response.respond_to?(:map)
    resp.parsed_response.map do |entry|
      metadata = if entry[0].match(UpdateStream.decimation_tag).nil?
                   __get_metadata(entry[0])
                 else
                   {} # decimation entry, no need to pull metadata
                 end
      # The streams are not pure attributes, pull them out
      elements = metadata.delete(:streams) || []
      elements.each(&:symbolize_keys!)
      # map the legacy discrete flag to new type setting
      # discrete == True => type = event
      # discrete == False => type = continuous
      elements.map! do |e|
        next unless e[:type].nil?
        e[:display_type] = if e[:discrete]
                     'event'
                   else
                     'continuous'
                   end
        e
      end
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
    _set_path_metadata("#{db_folder.path}/info",
                       __build_folder_metadata(db_folder))
  end

  def set_stream_metadata(db_stream)
    _set_path_metadata(db_stream.path,
                       __build_stream_metadata(db_stream))
  end

  def get_count(path, start_time, end_time)
    resp = self.class.get("#{@url}/stream/extract",
                          query: {
                            path: path,
                            start: start_time,
                            end: end_time,
                            count: 1
                          })
    return nil unless resp.success?
    return resp.parsed_response.to_i
  rescue
    return nil
  end

  def get_data(path, start_time, end_time)
    resp = self.class.get("#{@url}/stream/extract",
                          query: {
                            path: path,
                            start: start_time,
                            end: end_time,
                            markup: 1
                          })
    return nil unless resp.success?
    return __parse_data(resp.parsed_response)
  rescue
    return nil
  end

  def get_intervals(path, start_time, end_time)
    resp = self.class.get("#{@url}/stream/intervals",
                          query: {
                            path: path,
                            start: start_time,
                            end: end_time
                          })
    return nil unless resp.success?
    return __parse_intervals(resp.parsed_response)
  rescue
    return nil
  end

  def _set_path_metadata(path, data)
    params = { path: path,
               data: data }.to_json
    begin
      response = self.class.post("#{@url}/stream/update_metadata",
                                 body: params,
                                 headers: { 'Content-Type' => 'application/json' })
    rescue
      return { error: true, msg: 'cannot contact NilmDB server' }
    end
    unless response.success?
      Rails.logger.warn("#{@url}: update_metadata(#{path})"\
                        " => #{response.code}:#{response.body}")
      return { error: true, msg: "error updating #{path} metadata" }
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

  # convert folder attributes to __config_key json
  def __build_stream_metadata(db_stream)
    attribs = db_stream.attributes
                       .slice('name', 'name_abbrev', 'description', 'hidden')
    # elements are called streams in the nilmdb metadata
    # and they don't have id or timestamp fields
    attribs[:streams] = db_stream.db_elements.map do |e|
      vals = e.attributes.except('id', 'created_at', 'updated_at', 'db_stream_id')
      vals[:discrete] = e.display_type=='event'
      vals
    end
    { config_key__: attribs.to_json }.to_json
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

  # create an array from string response
  def __parse_data(resp)
    return [] if resp.nil? # no data returned
    data = []
    add_break = false
    resp.split("\n").each do |row|
      next if row.empty? # last row is empty (\n)
      words = row.split(' ')
      # check if this is an interval
      if words[0] == '#'
        # this is a comment line, check if it is an interval boundary marker
        intervalStart = words[2].to_i if words[1] == 'interval-start'
        if words[1] == 'interval-end'
          intervalEnd = words[2].to_i
          add_break = true if intervalEnd != intervalStart
        end
        next
      end
      data.push(nil) if add_break # add a data break
      add_break = false
      # this is a normal row
      data.push(words.map(&:to_f))
    end
    data
  end

  # create horizontal line segments representing
  # the intervals
  #
  def __parse_intervals(resp)
    intervals = JSON.parse('[' + resp.chomp.gsub(/\r\n/, ',') + ']')
    data = []
    intervals.each do |interval|
      data.push([interval[0], 0])
      data.push([interval[1], 0])
      data.push(nil) # break up the intervals
    end
    data
  end
end
