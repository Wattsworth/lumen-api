module Joule
  class Adapter

    def initialize(url)
      @backend = Backend.new(url)
    end

    def refresh(nilm)
      db_service = UpdateDb.new(db: nilm.db)
      result = StubService.new
      result.absorb_status(db_service.run(@backend.dbinfo, @backend.schema))
      module_service = UpdateModules.new(nilm)
      result.absorb_status(module_service.run(@backend.module_info))
      result
    end

    def refresh_stream(db_stream)
      data = @backend.stream_info(db_stream)
      service = UpdateStream.new(db_stream, data)
      service.run
    end

    def save_stream(db_stream)
      @backend.update_stream(db_stream)
    end

    def save_folder(db_folder)
      @backend.update_folder(db_folder)
    end

    def load_data(db_stream, start_time, end_time, elements=[], resolution=nil)
      data_service = LoadStreamData.new(@backend)
      data_service.run(db_stream, start_time, end_time, elements, resolution)
      unless data_service.success?
        return nil
      end
      {
          data: data_service.data,
          decimation_factor: data_service.decimation_factor
      }
    end
    def node_type
      'joule'
    end
  end
end