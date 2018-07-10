module Nilmdb
  class Adapter

    def initialize(url)
      @backend = Backend.new(url)
    end

    def refresh(db:)
      db_service = UpdateDb.new(db: db)
      db_service.run(@backend.dbinfo, @backend.schema)
    end

    def refresh_stream(db_stream)
      entries = @backend.stream_info(db_stream)
      service = UpdateStream.new(db_stream,
                                 entries[:base_entry],
                                 entries[:decimation_entries])
      service.run
    end

    def save_stream(db_stream)
      @backend.set_stream_metadata(db_stream)
    end

    def save_folder(db_folder)
      @backend.set_folder_metadata(db_folder)
    end

    def load_data(db_stream, start_time, end_time, elements=[], resolution=nil)
      data_service = LoadStreamData.new(@backend)
      data_service.run(db_stream, start_time, end_time, elements, resolution)
      unless data_service.success?
        return nil
      end
      {data: data_service.data,
       decimation_factor: data_service.decimation_factor}
    end

    def node_type
      'nilmdb'
    end

  end
end
