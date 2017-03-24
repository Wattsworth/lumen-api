class MockLoadStreamData
  include ServiceStatus
  attr_reader :data, :run_count

  def initialize(dataset)
    super()
    @dataset = dataset
    @data = nil
    @run_count = 0
  end
  def run(db_stream, start_time, end_time)
    @data = @dataset.select{|d| d[:stream]==db_stream}.first[:data]
    @run_count += 1
    if(@data == nil)
      self.add_error('could not retrieve stream data')
      return nil
    else
      self.reset_messages
    end
    return self
  end
end
