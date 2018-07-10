# frozen_string_literal: true

# Creates a dataset array from the given stream
# at the highest resolution allowed by the db
#
class BuildDataset
  include ServiceStatus
  attr_reader :data, :legend

  def initialize(node_adapter)
    super()
    @node_adapter = node_adapter
    @data = [] # [[ts, val1, val2, val3, ...],
               # [ts, val1, val2, val3, ...]]
    @legend = {
      start_time: '',
      end_time: '',
      num_rows: '',
      decimation_factor: 1,
      columns: [], # [{index: 1, name: 'time', units: 'us'},...]
      notes: ''
    }
  end

  # fill @data with values from db_stream
  # and populate @legend
  def run(db_stream, start_time, end_time)
    result = @node_adapter.load_data(db_stream, start_time, end_time)
    if result.nil?
      add_error("unable to retrieve data for #{db_stream.path}")
      return self
    end
    @data = _build_dataset(result[:data])
    @legend[:columns]           = _build_legend_columns(result[:data], db_stream)
    @legend[:start_time]        = start_time
    @legend[:end_time]          = end_time
    @legend[:decimation_factor] = result[:decimation_factor]
    @legend[:num_rows]          = @data.length
    if @data.empty?
      @legend[:notes] = 'there is no data available over this interval'
    elsif @data[0].length!=db_stream.db_elements.length+1
      @legend[:notes] = 'some elements omitted due to insufficient decimation'
    end
    self
  end

  def _build_dataset(stream_data)
    #can only build a dataset if data is actually present (raw or decimated)
    valid_columns = stream_data.select{|d| d[:type]!='interval'}
    return [] if(valid_columns.empty?)

    column_values = valid_columns.map do |element_data|
      element_data[:values].select{|row| row!=nil}
    end
    return [] if column_values.first.empty?

    data_columns = []
    #first column is the timestamp
    data_columns << column_values.first.transpose[0]
    #...second column is the data,
    column_values.each do |values|
        #append values column wise
        data_columns << values.transpose[1]
    end
    #flip back to row wise
    data_columns.transpose
  end

  def _build_legend_columns(stream_data, db_stream)
    legend_columns = [{index: 1, name: 'time', units: 'us'}]
    legend_index=2 #1 is for timestamp
    stream_data.each do |d|
      next if d[:type]=='interval'
      element = db_stream.db_elements.find_by_id(d[:id])
      legend_columns<<{
        index: legend_index,
        name: element.name,
        units: element.units.blank? ? 'no units': element.units
      }
      legend_index+=1
    end
    legend_columns
  end
end
