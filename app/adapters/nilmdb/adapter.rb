module Nilmdb
  class Adapter
    attr_accessor :backend

    def initialize(url)
      @backend = Backend.new(url)
    end

    def refresh(nilm)
      db_service = UpdateDb.new(nilm.db)
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

    def download_instructions(db_stream, start_time, end_time)
      "# --------- NILMTOOL INSTRUCTIONS ----------
#
# raw data can be accessed using nilmtool, run:
#
# $> nilmtool -u #{@backend.url} extract -s @#{start_time} -e @#{end_time} #{db_stream.path}
#
# ------------------------------------------"
    end
    def node_type
      'nilmdb'
    end

    # === ANNOTATIONS ===
    def create_annotation(annotation)
      path = annotation.db_stream.path
      # returns an annotation object
      annotations_json = @backend.read_annotations(path)
      # find max id
      if annotations_json.length > 0
        new_id = annotations_json.map{|a| a["id"]}.max + 1
      else
        new_id = 1
      end
      annotation.id = new_id
      annotations_json.push({
          "id": new_id,
          "title": annotation.title,
          "content": annotation.content,
          "start": annotation.start_time,
          "end": annotation.end_time })
      @backend.write_annotations(path, annotations_json)
    end

    def get_annotations(db_stream)
      annotations = []
      @backend.read_annotations(db_stream.path).
          map do |json|
            annotation = Annotation.new
            annotation.id = json["id"]
            annotation.title = json["title"]
            annotation.content = json["content"]
            annotation.start_time = json["start"]
            annotation.end_time = json["end"]
            annotation.db_stream = db_stream
            annotations.push(annotation)
          end
      annotations
    end

    def delete_annotation(annotation)
      path = annotation.db_stream.path
      updated_annotations =
          @backend.read_annotations(path).select do |json|
            json["id"] != annotation.id
          end
      @backend.write_annotations(path, updated_annotations)
    end

    def edit_annotation(id, title, content, stream)
      path = stream.path
      json = @backend.read_annotations(path)
      index = json.index{ |item| item['id']== id.to_i}
      raise "error, invalid annotation id" if index.nil?
      # find the specified id
      json[index]['title'] = title
      json[index]['content'] = content
      @backend.write_annotations(path, json)
      annotation = Annotation.new
      annotation.id = json[index]["id"]
      annotation.title = json[index]["title"]
      annotation.content = json[index]["content"]
      annotation.start_time = json[index]["start"]
      annotation.end_time = json[index]["end"]
      annotation.db_stream = stream
      annotation
    end
  end
end
