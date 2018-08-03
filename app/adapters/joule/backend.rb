#frozen_string_literal: true
module Joule
  # Wrapper around Joule HTTP service
  class Backend
    include HTTParty
    default_timeout 5
    open_timeout 5
    read_timeout 5

    attr_reader :url

    def initialize(url)
     @url = url
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
       resp = self.class.get("#{@url}/modules.json")
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
        #TODO: handle interval data
        return nil unless resp.success?
      rescue
        return nil
      end
      resp.parsed_response.symbolize_keys
    end
  end
end
