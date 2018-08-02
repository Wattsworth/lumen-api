# frozen_string_literal: true

# Mock class to test clients
class MockDataDbAdapter
  attr_reader :url

  def initialize(decimations=nil, start_time:, end_time:, raw_count:, data:)
    @start_time = start_time
    @end_time = end_time
    @raw_count = raw_count
    @data = data
    @last_path = nil
    @url = "http://mockbackend/nilmdb"
    # set to an array of valid decimation levels, if left blank assume all decimations exist
    @decimations = decimations
  end

  def get_data(path, start_time, end_time)
    #as long as start and end time are within
    #bounds return the 'data'
    @last_path = path
    if end_time<@start_time ||
       start_time>@end_time
       return []
    end
    @last_path = path
    @data
  end

  def get_count(path, start_time, end_time)

     matches = /-(\d+)$/.match(path)
     #raw stream, return raw_count
     if matches == nil
       #as long as start and end time are within
       #bounds return raw_count/decim level
       if end_time<@start_time ||
           start_time>@end_time
         return 0
       else
         return @raw_count
       end
     end
     #decimated return what would be left
     level = matches[1].to_i
     if not @decimations.nil?
       # make sure this level is in the decimations array
       unless @decimations.include?(level)
         return nil
       end
       #as long as start and end time are within
       #bounds return raw_count/decim level
       if end_time<@start_time ||
           start_time>@end_time
         return 0
       else
         return @raw_count/level
       end
       # decimations are not specified, assume they exist
     else
       #as long as start and end time are within
       #bounds return raw_count/decim level
       if end_time<@start_time ||
           start_time>@end_time
         return 0
       else
         return @raw_count/level
       end
     end
  end

  def get_intervals(path, start_time, end_time)
    #as long as start and end time are within
    #bounds return intervals
    if end_time<@start_time ||
       start_time>@end_time
       return 0
    end
    @last_path = path
    @data
  end

  def level_retrieved
    return nil if @last_path==nil
    matches = /-(\d+)$/.match(@last_path)
    return 1 if matches == nil
    matches[1].to_i
  end
end
