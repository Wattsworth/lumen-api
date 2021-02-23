require "benchmark"
# frozen_string_literal: true
# Loads data for specified elements
class LoadElementData
  include ServiceStatus
  attr_reader :data, :start_time, :end_time

  def initialize
    super()
    @data = []
    @start_time = nil
    @end_time = nil
  end

  # load data for the array of specified elements
  # start_time and end_time are unix us
  # if start_time is nil it is set to earliest timestamp
  # if end_time is nil it is set to latest timestamp
  # if resolution is nil, retrieve highest resolution possible

  #
  # sets data
  # data:
  #   [{id: element_id, values: [...]},
  #    {id: element_id, values: [...]},...]
  # see load_stream_data for details on the value structure
  #
  def run(elements, start_time, end_time, resolution = nil)
    #1 figure out what streams need to be pulled
    req_streams = []
    elements.each do |elem|
      unless req_streams.include?(elem.db_stream)
        req_streams << elem.db_stream
      end
    end

    # ----------- REMOVED FOR SPEED, NOT NECESSARY ------------------------
    # #2 compute bounds by updating stream info if start/end are missing
    # if start_time==nil || end_time==nil
    #   req_streams.map do |stream|
    #     adapter = NodeAdapterFactory.from_nilm(stream.db.nilm)
    #     if adapter.nil?
    #       add_error("cannot contact installation")
    #       return self
    #     end
    #     adapter.refresh_stream(stream)
    #   end
    # end
    #
    # #3 compute start and end times if nil
    # streams_with_data = req_streams.select{|stream| stream.total_time > 0}
    # if (start_time == nil || end_time == nil) && streams_with_data.empty?
    #   add_error("no time bounds for requested elements, refresh database?")
    #   return self
    # end
    # @start_time = start_time
    # @end_time = end_time
    # if start_time == nil
    #   @start_time = streams_with_data
    #     .sort_by{|x| x.start_time}
    #     .first.start_time
    # end
    # if end_time == nil
    #   @end_time = streams_with_data
    #     .sort_by{|x| -1*x.end_time}
    #     .first.end_time
    # end
    # ------------------------- END MODIFICATION ------------------------------

    @start_time = start_time
    @end_time = end_time
    if (not @start_time.nil?) and (not @end_time.nil?) and (@start_time > @end_time)
      add_error("invalid time bounds")
      return self
    end
    #4 pull data from streams
    combined_data = []
    req_streams.each do |stream|
      stream_elements = elements.select{|e| e.db_stream_id==stream.id}.to_a
      adapter = NodeAdapterFactory.from_nilm(stream.db.nilm)
      result = adapter.load_data(stream, @start_time, @end_time,stream_elements,resolution)
      if not result.nil?
        combined_data.concat(result[:data])
      else
        #create error entries
        error_entries = stream_elements.map do |e|
          {id: e.id, type: 'error', values: nil}
        end
        combined_data.concat error_entries
        add_warning("unable to retrieve data for #{stream.path}")
      end
    end
    #5 extract requested elements from the stream datasets
    req_element_ids = elements.pluck(:id)
    @data = combined_data.select{|d| req_element_ids.include? d[:id] }
    #6 set the time boundaries if they were nil
    @start_time = @start_time.nil? ? _data_start : @start_time
    @end_time = @end_time.nil? ? _data_end : @end_time
    self
  end

  def _data_start
    min_start = nil
    @data.each do |data|
      # find the first row of data (interval boundaries are nil)
      start_idx = 0
      while start_idx < data[:values].count
        break unless data[:values][start_idx].nil?
        start_idx +=1
      end
      start_row=data[:values][start_idx]
      unless start_row.nil?
        data_start = start_row[0]
        min_start = min_start.nil? ? data_start : [data_start,min_start].min
      end
    end
    min_start
  end

  def _data_end
    max_end = nil
    @data.each do |data|
      # find the last row of data (interval boundaries are nil)
      end_idx = data[:values].count-1
      while end_idx >=0
        break unless data[:values][end_idx].nil?
        end_idx -=1
      end
      last_row=data[:values][end_idx]
      unless last_row.nil?
        data_end = last_row[0]
        max_end = max_end.nil? ? data_end : [data_end,max_end].max
      end
    end
    max_end
  end
end
