# frozen_string_literal: true

# Loads stream data over specified interval
class LoadStreamData
  include ServiceStatus
  attr_reader :data, :data_type

  def initialize(db_adapter)
    super()
    @db_adapter = db_adapter
    @data = []
    @data_type = 'unset' # interval, raw, decimated
  end

  # load data at or below the resolution of the
  # associated database, sets data and data_type
  #
  # sets data and data_type
  # data_type: raw
  # data:
  #   [{id: element_id, values: [[ts,y],[ts,y],nil,[ts,y]]},...]
  # data_type: interval
  # data:
  #   [{id: element_id, values: [[start,0],[end,0],nil,...]}]
  # data_type: decimated
  # data:
  #   [{id: element_id, values: [[ts,y,ymin,ymax],[ts,y,ymin,ymax],nil,...]}]
  #
  def run(db_stream, start_time, end_time)
    resolution = db_stream.db.max_points_per_plot
    valid_decim = findValidDecimationLevel(db_stream, start_time)
    # valid_decim is the highest resolution, find one we can plot
    plottable_decim = findPlottableDecimationLevel(
      db_stream, valid_decim, start_time, end_time, resolution
    )
    if plottable_decim.nil?
      #check if its nil becuase the nilm isn't available
      return self unless self.success?
      # data is not sufficiently decimated, get intervals from
      # the valid decimation level (highest resolution)
      path = __build_path(db_stream, valid_decim.level)
      resp = @db_adapter.get_intervals(path, start_time, end_time)
      @data_type = 'interval'
      @data = __build_interval_data(db_stream, resp)
      return self
    end
    # request is plottable, see if we can get the raw (level 1) data
    path = __build_path(db_stream, plottable_decim.level)
    resp = @db_adapter.get_data(path, start_time, end_time)
    if resp.nil?
      add_error("cannot get data for [#{path}] @ #{@db_adapter.url}")
      return self
    end

    if plottable_decim.level == 1
      @data_type = 'raw'
      @data = __build_raw_data(db_stream, resp)
    else
      @data_type = 'decimated'
      @data = __build_decimated_data(db_stream, resp)
    end
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
    db_stream, valid_decim, start_time, end_time, _resolution
  )

    path = db_stream.path
    path += "~decim-#{valid_decim.level}" if valid_decim.level > 1
    # figure out how much data this stream has over the interval
    count = @db_adapter.get_count(path, start_time, end_time)
    if count.nil?
      add_error("cannot get count for [#{path}] @ #{@db_adapter.url}")
      return nil
    end
    # find out how much raw data exists over the specified interval
    raw_count = count * valid_decim.level
    # now we can find the right decimation level for plotting
    max_count = db_stream.db.max_points_per_plot
    # if the valid decim can be plotted, use it
    return valid_decim if raw_count <= max_count
    # otherwise look for a higher decimation level
    found_valid_decim = false
    db_stream.db_decimations
             .where('level >= ?', valid_decim.level)
             .order(:level)
             .each do |decim|
      if raw_count / decim.level <= max_count
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

  def __build_raw_data(db_stream, resp)
    elements = db_stream.db_elements.order(:column)
    data = elements.map { |e| { id: e.id, values: [] } }
    resp.each do |row|
      if row.nil? # add an interval break to all the elements
        data.each { |d| d[:values].push(nil) }
        next
      end
      ts = row[0]
      elements.each_with_index do |elem, i|
        data[i][:values].push([ts, __scale_value(row[1+i],elem)])
      end
    end
    return data
  end

  def __build_decimated_data(db_stream, resp)
    elements = db_stream.db_elements.order(:column)
    data = elements.map { |e| { id: e.id, values: [] } }
    resp.each do |row|
      if row.nil? # add an interval break to all the elements
        data.each { |d| d[:values].push(nil) }
        next
      end
      ts = row[0]
      elements.each_with_index do |elem, i|
        mean_offset = 0
        min_offset = elements.length
        max_offset = elements.length*2
        mean = __scale_value(row[1+i+mean_offset],elem)
        min =  __scale_value(row[1+i+min_offset], elem)
        max =  __scale_value(row[1+i+max_offset], elem)
        tmp_min = [min,max].min
        max = [min,max].max
        min = tmp_min
        data[i][:values].push([ts,mean,min,max])
      end
    end
    return data
  end

  def __build_interval_data(db_stream, resp)
    elements = db_stream.db_elements.order(:column)
    elements.map { |e| { id: e.id, values: resp } }
  end

  def __scale_value(value,element)
    (value.to_f-element.offset)*element.scale_factor
  end
end
