# frozen_string_literal: true

# Handles construction of DbFolder objects
class UpdateFile
  include ServiceStatus

  def initialize(file, base_entry, decimation_entries)
    @file = file
    @base_entry = base_entry
    @decimation_entries = decimation_entries
    super()
  end

  def run
    __update_file(@file, @base_entry, @decimation_entries)
    self
  end

  # regex matching the ~decimXX ending on a stream path
  def self.decimation_tag
    /~decim-([\d]+)$/
  end

  # create or update a DbFile object at the
  # specified path.
  def __update_file(file, base_entry, decimation_entries)
    file.update_attributes(base_entry[:attributes])
    file.save!
    __build_decimations(file: file,
                        entry_group: decimation_entries)
    __build_streams(file: file, stream_data: base_entry[:streams])
  end

  # create or update DbDecimations for the
  # specified DbFile
  def __build_decimations(file:, entry_group:)
    entry_group.each do |entry|
      level = entry[:path].match(UpdateFile.decimation_tag)[1].to_i
      decim = file.db_decimations.find_by_level(level)
      decim ||= DbDecimation.new(db_file: file, level: level)
      decim.update_attributes(entry[:attributes])
      decim.save!
    end
  end

  # create or update DbStreams for the
  # specified DbFile
  def __build_streams(file:, stream_data:)
    file.column_count.times do |x|
      stream = file.db_streams.find_by_column(x)
      stream ||= DbStream.new(db_file: file)
      # check if there is stream metadata for column x
      entry = stream_data.select { |meta| meta[:column] == x }
      # use the metadata if present
      stream.update_attributes(entry[0] || {})
      stream.save!
    end
  end
end
