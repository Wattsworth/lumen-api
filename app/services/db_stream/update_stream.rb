# frozen_string_literal: true

# Handles construction of DbFolder objects
class UpdateStream
  include ServiceStatus
  attr_reader :start_time, :end_time, :size_on_disk

  def initialize(stream, base_entry, decimation_entries)
    @stream = stream
    @base_entry = base_entry
    @decimation_entries = decimation_entries
    # initialize extents, these set during run
    @start_time = nil
    @end_time = nil
    @size_on_disk = 0
    super()
  end

  def run
    __update_stream(@stream, @base_entry, @decimation_entries)
    set_notice("Stream updated")
    self
  end

  # regex matching the ~decimXX ending on a stream path
  def self.decimation_tag
    /~decim-([\d]+)$/
  end

  # create or update a DbStream object at the
  # specified path.
  def __update_stream(stream, base_entry, decimation_entries)
    # use default attributes if metadata is corrupt
    unless stream.update_attributes(base_entry[:attributes])
      stream.use_default_attributes
      Rails.logger.warn("corrupt metadata: #{stream.path}")

    end
    __compute_extents([base_entry] + decimation_entries)
    stream.start_time = @start_time
    stream.end_time = @end_time
    stream.size_on_disk = @size_on_disk
    stream.save!

    __build_decimations(stream: stream,
                        entry_group: decimation_entries)
    __build_elements(stream: stream, stream_data: base_entry[:elements])
  end

  # create or update DbDecimations for the
  # specified DbStream
  def __build_decimations(stream:, entry_group:)
    if !entry_group.empty?
      Rails.logger.warn("deleting decimations for #{stream.path}")
      stream.db_decimations.destroy_all #remove existing decimations
    end
    entry_group.each do |entry|
      level = entry[:path].match(UpdateStream.decimation_tag)[1].to_i
      decim = stream.db_decimations.find_by_level(level)
      decim ||= DbDecimation.new(db_stream: stream, level: level)
      decim.update_attributes(entry[:attributes])

      #decim.save!
    end
  end

  # create or update DbStreams for the
  # specified DbStream
  def __build_elements(stream:, stream_data:)
    stream.column_count.times do |x|
      element = stream.db_elements.find_by_column(x)
      element ||= DbElement.new(db_stream: stream, column: x,
        display_type: 'continuous')
      # check if there is stream metadata for column x
      entry = stream_data.select { |meta| meta[:column] == x }
      # use the metadata if present
      unless element.update_attributes(entry[0] || {})
        element.use_default_attributes
        element.save!
        Rails.logger.warn(stream_data)
        Rails.logger.warn("corrupt metadata: #{stream.path}:"\
                          "e#{element.column}")
      end
    end
  end

  # compute the time range and total size of this stream
  # accepts an array of entries (include base & decim)
  def __compute_extents(entries)
    entries.map { |x| x[:attributes] }.each do |attrs|
      next if (attrs[:total_rows]).zero?
      if @start_time.nil?
        @start_time = attrs[:start_time]
        @end_time = attrs[:end_time]
      end
      @start_time = [@start_time, attrs[:start_time]].min
      @end_time = [@end_time, attrs[:end_time]].max
      @size_on_disk += attrs[:total_rows] *
                       __bytes_per_row(attrs[:data_type])
    end
  end

  # compute how many bytes are required per row based
  # on the datatype (float32_8 => 4*8+8)
  def __bytes_per_row(data_type)
    regex = /[a-z]*(\d*)_(\d*)/.match(data_type)
    dtype_bytes = regex[1].to_i / 8
    num_cols = regex[2].to_i
    ts_bytes = 8
    ts_bytes + num_cols * dtype_bytes
  end
end
