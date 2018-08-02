# frozen_string_literal: true
module Joule
  # Refresh a particular stream and load its data information
  class UpdateStream
    include ServiceStatus

    def initialize
      super()
    end

    def run(db_stream, schema, data_info)
      attrs = schema.slice(*DbStream.defined_attributes)
      # add in extra attributes that require conversion
      attrs[:data_type] = "#{schema[:datatype].downcase}_#{schema[:elements].count}"
      attrs[:joule_id] = schema[:id]
      # add in data info
      attrs[:start_time] = data_info[:start]
      attrs[:end_time] = data_info[:end]
      attrs[:total_time] = data_info[:end] - data_info[:start]
      attrs[:total_rows] = data_info[:rows]
      db_stream.update_attributes(attrs)
      schema[:elements].each do |element_config|
        attrs = element_config.slice(*DbElement.defined_attributes)
        # add in extra attributes that require conversion
        attrs[:display_type] = element_config[:display_type].downcase
        attrs[:plottable] = true
        elem = db_stream.db_elements.find_by_column(element_config[:index])
        elem.update_attributes(attrs)
      end
      self
    end
  end
end