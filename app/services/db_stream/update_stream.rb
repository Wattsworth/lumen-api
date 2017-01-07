# frozen_string_literal: true

# Handles construction of DbFolder objects
class UpdateStream
  include ServiceStatus

  def initialize(stream, base_entry, decimation_entries)
    @stream = stream
    @base_entry = base_entry
    @decimation_entries = decimation_entries
    super()
  end

  def run
    __update_stream(@stream, @base_entry, @decimation_entries)
    self
  end

  # regex matching the ~decimXX ending on a stream path
  def self.decimation_tag
    /~decim-([\d]+)$/
  end

  # create or update a DbStream object at the
  # specified path.
  def __update_stream(stream, base_entry, decimation_entries)
    stream.update_attributes(base_entry[:attributes])
    stream.save!
    __build_decimations(stream: stream,
                        entry_group: decimation_entries)
    __build_elements(stream: stream, stream_data: base_entry[:elements])
  end

  # create or update DbDecimations for the
  # specified DbStream
  def __build_decimations(stream:, entry_group:)
    entry_group.each do |entry|
      level = entry[:path].match(UpdateStream.decimation_tag)[1].to_i
      decim = stream.db_decimations.find_by_level(level)
      decim ||= DbDecimation.new(db_stream: stream, level: level)
      decim.update_attributes(entry[:attributes])
      decim.save!
    end
  end

  # create or update DbStreams for the
  # specified DbStream
  def __build_elements(stream:, stream_data:)
    stream.column_count.times do |x|
      element = stream.db_elements.find_by_column(x)
      element ||= DbElement.new(db_stream: stream)
      # check if there is stream metadata for column x
      entry = stream_data.select { |meta| meta[:column] == x }
      # use the metadata if present
      element.update_attributes(entry[0] || {})
      element.save!
    end
  end
end
