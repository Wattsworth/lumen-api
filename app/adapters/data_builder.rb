class DataBuilder

  def self.build_raw_data(elements, resp)
    data = elements.map { |e| { id: e.id, type: 'raw', values: [] } }
    resp.each do |row|
      if row.nil? # add an interval break to all the elements
        data.each { |d| d[:values].push(nil) }
        next
      end
      ts = row[0]
      elements.each_with_index do |elem, i|
        data[i][:values].push([ts, self.scale_value(row[1 + elem.column], elem)])
      end
    end
    data
  end

  def self.build_decimated_data(elements, resp)
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

  def self.build_interval_data(elements, resp)
    elements.map { |e| { id: e.id, type: 'interval', values: resp } }
  end

  # for data that cannot be represented as decimations
  # eg: events, compute intervals from the actual decimated data
  def self.build_intervals_from_decimated_data(elements, resp)

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

  def self.scale_value(value, element)
    (value.to_f - element.offset) * element.scale_factor
  end
end