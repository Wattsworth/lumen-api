#frozen_string_literal: true
module Joule
  # Wrapper around Joule HTTP service
  class Backend
    include HTTParty
    default_timeout 5
    open_timeout 5
    read_timeout 5

    attr_reader :url

    def initialize(url, key)
      @url = url
      self.class.default_options[:headers] = {'X-API-KEY': key}
      self.class.default_options[:verify] = false

      # TODO handle SSL configuration
    end

    def dbinfo
     begin
       resp = self.class.get("#{@url}/version")
       return nil unless resp.success?
       version = resp.parsed_response

       resp = self.class.get("#{@url}/dbinfo")
       return nil unless resp.success?
       info = resp.parsed_response
     rescue
       return nil
     end
     # if the site exists but is not a nilm...
     required_keys = %w(size other free reserved)
     unless info.respond_to?(:has_key?) &&
         required_keys.all? { |s| info.key? s }
       return nil
     end
     {
         version: version,
         size_db: info['size'],
         size_other: info['other'],
         size_total: info['size'] + info['other'] + info['free'] + info['reserved']
     }
    end

    def db_schema
     begin
       resp = self.class.get("#{@url}/streams.json")
       return nil unless resp.success?
     rescue
       return nil
     end
     resp.parsed_response.deep_symbolize_keys
    end

    def module_schemas
     begin
       resp = self.class.get("#{@url}/modules.json?statistics=1")
       return nil unless resp.success?
       items = resp.parsed_response
       # if the site exists but is not a joule server...
       required_keys = %w(name inputs outputs)
       items.each do |item|
         return nil unless item.respond_to?(:has_key?) &&
                required_keys.all? { |s| item.key? s }
         item.symbolize_keys!
       end
     rescue
       return nil
     end
     items
    end

    def module_interface(joule_module, req)
     self.class.get("#{@url}/interface/#{joule_module.joule_id}/#{req}")
    end

    def module_post_interface(joule_module, req)
      self.class.post("#{@url}/interface/#{joule_module.joule_id}/#{req}")
    end

    def stream_info(joule_id)
      begin
       resp = self.class.get("#{@url}/stream.json?id=#{joule_id}")
       return nil unless resp.success?
      rescue
       return nil
      end
      resp.parsed_response.deep_symbolize_keys
    end

    def load_data(joule_id, start_time, end_time, resolution)
      query = {'id': joule_id, 'max-rows': resolution}
      query['start'] = start_time unless start_time.nil?
      query['end'] = end_time unless end_time.nil?
      options = { query: query}
      begin
        resp = self.class.get("#{@url}/data.json", options)
        if resp.code==400 and resp.body.include?('decimated data is not available')
          return {success: false, result: "decimation error"}
        end
        return {success: false, result: resp.body} unless resp.success?
      rescue
        return {success: false, result: "connection error"}
      end
      {success: true, result: resp.parsed_response.symbolize_keys}
    end

    def load_intervals(joule_id, start_time, end_time)
      query = {'id': joule_id}
      query['start'] = start_time unless start_time.nil?
      query['end'] = end_time unless end_time.nil?
      options = { query: query}
      begin
        resp = self.class.get("#{@url}/data/intervals.json", options)
        return {success: false, result: resp.body} unless resp.success?
      rescue
        return {success: false, result: "connection error"}
      end
      data = []
      resp.parsed_response.each do |interval|
        data.push([interval[0], 0])
        data.push([interval[1], 0])
        data.push(nil) # break up the intervals
      end
      {success: true, result: data}
    end

    def update_stream(db_stream)
      elements = []
      db_stream.db_elements.each do |elem|
        elements <<  {name: elem.name,
                      plottable: elem.plottable,
                      units: elem.units,
                      default_min: elem.default_min,
                      default_max: elem.default_max,
                      scale_factor: elem.scale_factor,
                      offset: elem.offset,
                      display_type: elem.display_type}
      end

      attrs = { name: db_stream.name,
                 description: db_stream.description,
                 elements: elements
                }
      begin
        response = self.class.put("#{@url}/stream.json",
                                  headers: { 'Content-Type' => 'application/json' },
                                  body: {
                                       id: db_stream.joule_id,
                                       stream: attrs}.to_json)
      rescue
        return { error: true, msg: 'cannot contact Joule server' }
      end
      unless response.success?
        return { error: true, msg: "error updating #{db_stream.path} metadata" }
      end
      { error: false, msg: 'success' }
    end

    def update_folder(db_folder)
      attrs = { name: db_folder.name,
                description: db_folder.description}
      begin
        response = self.class.put("#{@url}/folder.json",
                                  headers: { 'Content-Type' => 'application/json' },
                                  body: {
                                      id: db_folder.joule_id,
                                      folder: attrs}.to_json)
      rescue
        return { error: true, msg: 'cannot contact Joule server' }
      end
      unless response.success?
        return { error: true, msg: "error updating #{db_folder.path} metadata" }
      end
      { error: false, msg: 'success' }
    end

    # === ANNOTATION METHODS ===
    def create_annotation(annotation)
      data = {
          'stream_id': annotation.db_stream.joule_id,
          'title': annotation.title,
          'content': annotation.content,
          'start': annotation.start_time,
          'end': annotation.end_time}
      begin
        resp = self.class.post("#{@url}/annotation.json",
                                   headers: { 'Content-Type' => 'application/json' },
                                   body: data.to_json)
        raise "error creating annotations #{resp.body}" unless resp.success?
      rescue
        raise "connection error"
      end
      annotation.id = resp.parsed_response["id"]
      annotation
    end

    def get_annotations(stream_id)
      query = {'stream_id': stream_id}
      options = { query: query}
      begin
        resp = self.class.get("#{@url}/annotations.json", options)
        raise "error loading annotations #{resp.body}" unless resp.success?
      rescue
        raise "connection error"
      end
      resp.parsed_response
    end

    def delete_annotation(annotation_id)
      query = {'id': annotation_id}
      options = { query: query}
      begin
        resp = self.class.delete("#{@url}/annotation.json",
                                 options)
        raise "error deleting annotation #{resp.body}" unless resp.success?
      rescue
        raise "connection error"
      end
    end

    # === END ANNOTATION METHODS ===
  end
end
