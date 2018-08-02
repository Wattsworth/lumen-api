# frozen_string_literal: true
module Nilmdb
  # Loads stream data over specified interval
  class LoadStreamData
    include ServiceStatus
    attr_reader :data, :data_type, :decimation_factor

    def initialize(db_backend)
      super()
      @db_backend = db_backend
      @data = []
      @data_type = 'unset' # interval, raw, decimated
      @decimation_factor = 1
    end

    # load data at or below the resolution of the
    # associated database, sets data and data_type
    # specify a subset of elements as an optional array
    # if ommitted, all elements are extracted from the stream (expensive!)
    # optionally specify a resolution, if omitted, returns maximum resolution
    # allowed by the nilm
    #
    # sets data and data_type
    # data_type: raw
    # data:
    #   [{id: element_id, type: raw values: [[ts,y],[ts,y],nil,[ts,y]]},...]
    #
    # data_type: decimated
    # event data:
    #   [{id: element_id, type: interval, values: [[start,0],[end,0],nil,...]}]
    # continuous or discrete data:
    #   [{id: element_id, type: decimated, values: [[ts,y,ymin,ymax],[ts,y,ymin,ymax],nil,...]}]
    #
    # data_type: interval
    # data:
    #   [{id: element_id, type: interval, values: [[start,0],[end,0],nil,...]}]
    #
    def run(db_stream, start_time, end_time, elements = [], resolution=nil)

      # if elements are not explicitly passed, get all of them
      if elements.empty?
        elements = db_stream.db_elements.all.to_a
      end
      elements.sort_by!(&:column)

      resolution = if resolution.nil?
                     db_stream.db.max_points_per_plot
                   else
                     [db_stream.db.max_points_per_plot,resolution].min
                   end
      valid_decim = findValidDecimationLevel(db_stream, start_time)
      # valid_decim is the highest resolution, find one we can plot
      plottable_decim = findPlottableDecimationLevel(
        db_stream, valid_decim, start_time, end_time, resolution
      )


      if plottable_decim.nil?
        # check if its nil becuase the nilm isn't available
        return self unless success?
        # data is not sufficiently decimated, get intervals from
        # the valid decimation level (highest resolution)
        path = __build_path(db_stream, valid_decim.level)
        resp = @db_backend.get_intervals(path, start_time, end_time)
        @data_type = 'interval'
        @data = __build_interval_data(elements, resp)
        return self
      end
      # request is plottable, see if we can get the data
      @decimation_factor = plottable_decim.level
      path = __build_path(db_stream, plottable_decim.level)
      resp = @db_backend.get_data(path, start_time, end_time)

      if resp.nil?
        add_error("cannot get data for [#{path}] @ #{@db_backend.url}")
        return self
      end

      if plottable_decim.level == 1
        @data_type = 'raw'
        @data = __build_raw_data(elements, resp)
      else
        @data_type = 'decimated'
        decimateable_elements =
          elements.select{|e| %w(continuous discrete).include? e.display_type}
        interval_elements = elements.select{|e| e.display_type=='event'}
        @data = __build_decimated_data(decimateable_elements, resp) +
                __build_intervals_from_decimated_data(interval_elements, resp)

      end
      self
    end

    #===Description
    # Given a starting decimation level and time interval
    # find a decimation level that meets the target resolution
    #===Parameters
    # * +db_stream+ - DbStream object
    # * +start_time+ - unix timestamp in us
    #
    # returns: +decimation_level+ - DecimationLevel object
    # *NOTE:* if the data is too high resolution to request
    # (data is not sufficiently decimated),
    # the decimation level will be 0
    #
    def findPlottableDecimationLevel(
      db_stream, valid_decim, start_time, end_time, resolution
    )
      path = db_stream.path
      path += "~decim-#{valid_decim.level}" if valid_decim.level > 1
      # figure out how much data this stream has over the interval
      count = @db_backend.get_count(path, start_time, end_time)
      if count.nil?
        add_error("cannot get count for [#{path}] @ #{@db_backend.url}")
        return nil
      end
      # find out how much raw data exists over the specified interval
      raw_count = count * valid_decim.level
      # now we can find the right decimation level for plotting
      # if the valid decim can be plotted, use it
      return valid_decim if raw_count <= resolution
      # otherwise look for a higher decimation level
      found_valid_decim = false
      db_stream.db_decimations
               .where('level >= ?', valid_decim.level)
               .order(:level)
               .each do |decim|
        if raw_count / decim.level <= resolution
          # the lowest decimation level is the best
          return decim
        end
      end
      # all of the decimations have too much data
      # no plottable decimation exists
      nil
    end

    #===Description
    # Given the plot resolution and time interval, find the decimation
    # level with the highest resolution data possible. This means
    # find highest resolution stream that has a start_time before
    # the specified start_time
    #===Parameters
    # * +db_stream+ - DbStream object
    # * +start_time+ - unix timestamp in us
    #
    # returns: +decimation_level+ - DecimationLevel object
    #
    def findValidDecimationLevel(db_stream, start_time)
      # assume raw stream is a valid level (best resolution)
      validDecim = DbDecimation.new(level: 1)
      # check if raw stream has the data
      if !db_stream.start_time.nil? &&
         db_stream.start_time <= start_time
        return validDecim
      end
      # keep track of the level thats missing the least data, this will be used
      # if no level can be found with all the data
      min_gap = db_stream.start_time - start_time

      db_stream.db_decimations.order(:level).each do |decim|
        # skip empty decimation levels
        next if decim.start_time.nil? || decim.end_time.nil?
        # the first (lowest) level with data over the interval is the best answer
        return decim if decim.start_time <= start_time
        # this level doesn't contain all the requested data, see how much its missing
        gap = decim.start_time - start_time
        if min_gap.nil? || gap < min_gap
          min_gap = gap
          validDecim = decim
        end
      end
      validDecim
    end

    def __build_path(db_stream, level)
      return db_stream.path if level == 1
      "#{db_stream.path}~decim-#{level}"
    end

    def __build_raw_data(elements, resp)
      data = elements.map { |e| { id: e.id, type: 'raw', values: [] } }
      resp.each do |row|
        if row.nil? # add an interval break to all the elements
          data.each { |d| d[:values].push(nil) }
          next
        end
        ts = row[0]
        elements.each_with_index do |elem, i|
          data[i][:values].push([ts, __scale_value(row[1 + elem.column], elem)])
        end
      end
      data
    end

    def __build_decimated_data(elements, resp)
      # if elements is empty we don't need to do anything
      return [] if elements.empty?

      #prepare the data structure
      data = elements.map { |e| { id: e.id, type: 'decimated', values: Array.new(resp.length) } }

      #set up constants so we compute them once
      mean_offset = 0
      min_offset = elements.first.db_stream.db_elements.length
      max_offset = elements.first.db_stream.db_elements.length * 2

      resp.each_with_index do |row, k|
        if row.nil? # add an interval break to all the elements
          data.each { |d| d[:values][k]=nil }
          next
        end
        ts = row[0]
        elements.each_with_index do |elem, i|
          #mean = __scale_value(row[1 + elem.column + mean_offset], elem)
          #min =  __scale_value(row[1 + elem.column + min_offset], elem)
          #max =  __scale_value(row[1 + elem.column + max_offset], elem)
          mean = (row[1 + elem.column + mean_offset] - elem.offset) * elem.scale_factor
          min =  (row[1 + elem.column + min_offset] - elem.offset) * elem.scale_factor
          max = (row[1 + elem.column + max_offset] - elem.offset) * elem.scale_factor
          tmp_min = [min, max].min
          max = [min, max].max
          min = tmp_min
          data[i][:values][k]=[ts, mean, min, max]
        end
      end
      data
    end

    def __build_interval_data(elements, resp)
      elements.map { |e| { id: e.id, type: 'interval', values: resp } }
    end

    # for data that cannot be represented as decimations
    # eg: events, compute intervals from the actual decimated data
    def __build_intervals_from_decimated_data(elements, resp)

      # if elements is empty we don't need to do anything
      return [] if elements.empty?
      # compute intervals from resp
      if resp.empty?
        elements.map do |e|
          { id: e.id,
            type: 'interval',
            values: [] }
        end
      end
      intervals = []
      interval_start = nil
      interval_end = nil
      resp.each do |row|
        if row.nil?
          if !interval_start.nil? && !interval_end.nil?
            # interval break and we know the start and end times
            intervals += [[interval_start, 0], [interval_end, 0], nil]
            interval_start = nil
          end
          next
        end
        if interval_start.nil?
          interval_start = row[0]
          next
        end
        interval_end = row[0]
      end

      if !interval_start.nil? && !interval_end.nil?
        intervals += [[interval_start, 0], [interval_end, 0]]
      end
      elements.map do |e|
        { id: e.id,
          type: 'interval',
          values: intervals }
      end
    end

    def __scale_value(value, element)
      (value.to_f - element.offset) * element.scale_factor
    end
  end
end