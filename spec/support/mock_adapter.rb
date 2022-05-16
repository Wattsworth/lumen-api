class MockAdapter
  attr_reader :run_count, :event_run_count

  def initialize(dataset=nil, events = nil)
    super()
    @dataset = dataset
    @events = events
    @run_count = 0
    @event_run_count = 0
  end
  def load_data(db_stream, start_time, end_time, elements=[], resolution=nil)
    data = @dataset.select{|d| d[:stream]==db_stream}.first[:data]
    @run_count += 1
    if data == nil
      return nil
    end
    {data: data, decimation_factor: 1}
  end
  def read_events(event_stream,max_events, start_time, end_time, filter)
    data = @events.select{|d| d[:event_stream]==event_stream}.first[:data]
    @event_run_count += 1
    data
  end
end