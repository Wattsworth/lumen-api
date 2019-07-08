module Joule
  class Adapter
    attr_accessor :backend

    def initialize(url, key)
      @backend = Backend.new(url, key)
    end

    def refresh(nilm)
      db_service = UpdateDb.new(nilm.db)
      result = StubService.new
      result.absorb_status(db_service.run(@backend.dbinfo, @backend.db_schema))
      module_service = UpdateModules.new(nilm)
      result.absorb_status(module_service.run(@backend.module_schemas))
      result
    end

    def refresh_stream(db_stream)
      data = @backend.stream_info(db_stream.joule_id)
      service = UpdateStream.new
      service.run(db_stream, data[:stream], data[:data_info])
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

    def download_instructions(db_stream, start_time, end_time)
      "# --------- JOULE INSTRUCTIONS ----------
#
# raw data can be accessed using the joule cli, run:
#
# $> joule -n #{@backend.url} data read -s #{start_time} -e #{end_time} #{db_stream.path}
#
# ------------------------------------------"
    end

    def module_interface(joule_module, req)
      @backend.module_interface(joule_module, req)
    end

    def module_post_interface(joule_module, req)
      @backend.module_post_interface(joule_module, req)
    end

    # === ANNOTATIONS ===
    def create_annotation(annotation)
      # returns an Annotation object
      @backend.create_annotation(annotation)
    end

    def get_annotations(db_stream)
      # returns an array of Annotation objects
      annotation_json = @backend.get_annotations(db_stream.joule_id)
      annotations = []
      annotation_json.each do |json|
        annotation = Annotation.new
        annotation.id = json["id"]
        annotation.title = json["title"]
        annotation.content = json["content"]
        annotation.start_time = json["start"]
        annotation.end_time = json["end"]
        # ignore joule stream_id parameter
        # use the db_stream model instead
        annotation.db_stream = db_stream
        annotations.push(annotation)
      end
      annotations
    end

    def delete_annotation(annotation)
      # returns nil
      @backend.delete_annotation(annotation.id)
    end
    # === END ANNOTATIONS ===

    def node_type
      'joule'
    end
  end
end