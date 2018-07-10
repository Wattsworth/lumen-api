class MockAdapter
  attr_reader :run_count

  def initialize(dataset)
    super()
    @dataset = dataset
    @run_count = 0
  end
  def load_data(db_stream, start_time, end_time, elements=[], resolution=nil)
    data = @dataset.select{|d| d[:stream]==db_stream}.first[:data]
    @run_count += 1
    if data == nil
      return nil
    end
    {data: data, decimation_factor: 1}
  end
end