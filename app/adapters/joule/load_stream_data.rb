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
      result = @backend.load_data(db_stream.joule_id, start_time, end_time, resolution)
      if result.nil?
        add_error("cannot get data for [#{db_stream.name}] @ #{@db_backend.url}")
        return self
      end
      # convert data into single array with nil's at interval boundaries
      data = []
      result[:data].each do |interval|
        data += interval
        data.push(nil)
      end
      if result[:decimated]
        @data = DataBuilder.build_decimated_data(elements,data)
        @data_type = 'decimated'
      else
        @data = DataBuilder.build_raw_data(elements,data)
        @data_type = 'raw'
      end
      #TODO: handle interval data
      @decimation_factor = 1 # TODO: fix this
    end
  end
end