# frozen_string_literal: true

# Loads data for specified elements
class LoadElementData
  include ServiceStatus
  attr_reader :data, :start_time, :end_time

  def initialize()
    super()
    @data = []
    @start_time = nil
    @end_time = nil
  end

  # load data for the array of specified elements
  # start_time and end_time are unix us
  # if start_time is nil it is set to earliest timestamp
  # if end_time is nil it is set to latest timestamp
  #
  # sets data
  # data:
  #   [{id: element_id, values: [...]},
  #    {id: element_id, values: [...]},...]
  # see load_stream_data for details on the value structure
  #
  def run(elements, start_time, end_time)
    #1 figure out what streams need to be pulled
    req_streams = []
    elements.each do |elem|
      unless req_streams.include?(elem.db_stream)
        req_streams << elem.db_stream
      end
    end
    #2 compute start and end times if nil
    streams_with_data = req_streams.select{|stream| stream.total_time > 0}
    if (start_time == nil || end_time == nil) && streams_with_data.empty?
      add_error("no time bounds for requested elements, refresh database?")
      return
    end
    @start_time = start_time
    @end_time = end_time
    if start_time == nil
      @start_time = streams_with_data
        .sort{|a,b| a.start_time < b.start_time }
        .first.start_time
    end
    if end_time == nil
      @end_time = streams_with_data
        .sort{|a,b| a.end_time > b.end_time }
        .first.end_time
    end
    if @start_time > @end_time
      add_error("invalid time bounds")
      return
    end
    #2 pull data from streams
    combined_data = []
    req_streams.each do |stream|
      adapter = DbAdapter.new(stream.db.url)
      data_service = LoadStreamData.new(adapter)
      data_service.run(stream, @start_time, @end_time)
      if data_service.success?
        combined_data.concat(data_service.data)
      else
        add_warning("unable to retrieve data for #{stream.name_path}")
      end
    end
    #3 extract requested elements from the stream datasets
    req_element_ids = elements.pluck(:id)
    @data = combined_data.select{|d| req_element_ids.include? d[:id] }
    return self
    end
  end
