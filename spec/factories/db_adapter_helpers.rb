# frozen_string_literal: true

# Mock class to test clients
class MockDataDbAdapter
  attr_reader :url

  def initialize(start_time:, end_time:, raw_count:, data:)
    @start_time = start_time
    @end_time = end_time
    @raw_count = raw_count
    @data = data
    @last_path = nil
    @url = "http://mockadapter/nilmdb"
  end

  def get_data(path, start_time, end_time)
    #as long as start and end time are within
    #bounds return the 'data'
    @last_path = path
    if(end_time<@start_time ||
       start_time>@end_time)
       return []
    end
    @last_path = path
    return @data
  end

  def get_count(path, start_time, end_time)
    #as long as start and end time are within
    #bounds return raw_count/decim level
    if(end_time<@start_time ||
       start_time>@end_time)
       return 0
     end
     matches = /-(\d+)$/.match(path)
     #raw stream, return raw_count
     return @raw_count if(matches==nil)
     #decimated return what would be left
     level = matches[1].to_i
     return @raw_count/level
  end

  def get_intervals(path, start_time, end_time)
    #as long as start and end time are within
    #bounds return intervals
    if(end_time<@start_time ||
       start_time>@end_time)
       return 0
    end
    @last_path = path
    return @data
  end

  def level_retrieved()
    return nil if @last_path==nil
    matches = /-(\d+)$/.match(@last_path)
    return 1 if matches == nil
    return matches[1].to_i
  end
end
