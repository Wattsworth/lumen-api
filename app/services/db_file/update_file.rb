# frozen_string_literal: true

# Handles construction of DbFolder objects
class UpdateFile
  attr_accessor :warnings, :errors

  def initialize(file, base_entry, decimation_entries)
    @file = file
    @base_entry = base_entry
    @decimation_entries = decimation_entries
    @warnings = []
    @errors = []
  end

  def run()
    return __update_file(@file, @base_entry, @decimation_entries)
  end

  # create or update a DbFile object at the
  # specified path.
  def __update_file(file, base_entry, decimation_entries:)
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
      level = entry[:path].match(decimation_tag)[1].to_i
      decim = file.db_decimations.find_by_level(level)
      decim ||= DbDecimation.new(db_file: file, level: level)
      decim.update_attributes(entry[:attributes])
      decim.save!
    end
  end

  # create or update DbStreams for the
  # specified DbFile
  def __build_streams(file:, stream_data:)
    return if stream_data.empty?
    stream_data.each do |entry|
      stream = file.db_streams.find_by_column(entry[:column])
      stream ||= DbStream.new(db_file: file)
      stream.update_attributes(entry)
      stream.save!
    end
  end
end