# frozen_string_literal: true
module Joule
  # Loads stream data over the specified interval
  class LoadStreamData
    include ServiceStatus
    attr_reader :data, :decimation_factor, :data_type


    def initialize(backend)
        super()
        @backend = backend
        @data = []
        @data_type = 'unset' # interval, raw, decimated
        @decimation_factor = 1
      end

    def run(db_stream, start_time, end_time, elements=[], resolution=nil)
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
      resp = @backend.load_data(db_stream.joule_id, start_time, end_time, resolution)
      unless resp[:success]
        if resp[:result] == 'decimation error'
          resp = @backend.load_intervals(db_stream.joule_id, start_time, end_time)
          if resp[:success]
            @data = DataBuilder.build_interval_data(elements, resp[:result])
            @data_type = 'interval'
            return self
          end
        end
        add_error("cannot get data for [#{db_stream.name}] @ #{@backend.url}: #{resp[:result]}")
        return self
      end

      # convert data into single array with nil's at interval boundaries
      result = resp[:result]
      data = []
      result[:data].each do |interval|
        data += interval
        data.push(nil)
      end
      if result[:decimation_factor] > 1
        @data_type = 'decimated'
        decimateable_elements =
            elements.select{|e| %w(continuous discrete).include? e.display_type}
        interval_elements = elements.select{|e| e.display_type=='event'}
        @data = DataBuilder.build_decimated_data(decimateable_elements, data) +
            DataBuilder.build_intervals_from_decimated_data(interval_elements, data)
      else
        @data = DataBuilder.build_raw_data(elements,data)
        @data_type = 'raw'
      end
      @decimation_factor = result[:decimation_factor]
      self
    end
  end
end