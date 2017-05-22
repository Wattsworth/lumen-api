# frozen_string_literal: true

# Creates a dataset array from the given stream
# at the highest resolution allowed by the db
#
class BuildDataset
  include ServiceStatus
  attr_reader :data, :legend

  def initialize
    super()
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
    adapter = DbAdapter.new(db_stream.db.url)
    data_service = LoadStreamData.new(adapter)
    data_service.run(db_stream, start_time, end_time)
    unless data_service.success?
      add_error("unable to retrieve data for #{stream.path}")
      return self
    end
    @data = _build_dataset(data_service.data)
    @legend[:columns]           = _build_legend_columns(data_service.data, db_stream)
    @legend[:start_time]        = start_time
    @legend[:end_time]          = end_time
    @legend[:decimation_factor] = data_service.decimation_factor
    @legend[:num_rows]          = @data.length
    if(@data[0].length!=db_stream.db_elements.length+1)
      @legend[:notes] = 'some elements omitted due to insufficient decimation'
    end
    self
  end

  def _build_dataset(stream_data)
    #can only build a dataset if data is actually present (raw or decimated)
    valid_columns = stream_data.select{|d| d[:type]!='interval'}
    return [] if(valid_columns.empty?)

    cleaned_columns = valid_columns.map do |element_data|
      element_data[:values].select{|row| row!=nil}
    end
    data_columns = []
    #first column is the timestamp
    data_columns << cleaned_columns.first.transpose[0]
    #add element data by column
    cleaned_columns.each do |data|
        data_columns << data.transpose[1]
    end
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
