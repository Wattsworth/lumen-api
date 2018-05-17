#frozen_string_literal: true

# Wrapper around Joule HTTP service
class JouleAdapter
 include HTTParty
 default_timeout 5
 open_timeout 5
 read_timeout 5

 attr_reader :url

 def initialize(url)
   @url = url
 end

 def module_info
   begin
     resp = self.class.get("#{@url}/modules.json")
     return nil unless resp.success?
     items = resp.parsed_response
     # if the site exists but is not a joule server...
     required_keys = %w(name exec_cmd)
     items.each do |item|
       return nil unless item.respond_to?(:has_key?) &&
              required_keys.all? { |s| item.key? s }
       item.symbolize_keys!
     end
   rescue
     return nil
   end
   return items
 end

 def module_interface(joule_module, req)
   self.class.get("#{@url}/module/#{joule_module.joule_id}/#{req}")
 end
end
