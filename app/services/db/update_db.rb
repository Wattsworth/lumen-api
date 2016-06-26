# frozen_string_literal: true

# Handles construction of database objects
class UpdateDb # rubocop:disable Metrics/ClassLength
  attr_accessor :warnings, :errors

  def initialize(db:)
    @db = db
    @warnings = []
    @errors = []
  end

  def run(db_adapter:)
    # create the root folder if it doesn't exist
    @db.root_folder ||= DbFolder.create(name: 'root', path: '/')
    @root_folder = @db.root_folder

    # create the entry array from the schema
    entries = __create_entries(db_adapter.schema)

    # parse the entries array
    # Note: @root_folder gets linked in on
    #       the first call to __build_folder
    __parse_folder_entries(parent: nil, entries: entries)
    @db.save
  end

  protected

  # Adds :chunks to each schema element
  # :chunks is an array of the entry's path elements
  # this makes it easier to traverse the database structure.
  # The array is reversed so the chunks can be popped off in order
  #   path: '/data/meter/prep-a'
  #   chunks: ['prep-a','meter','data']
  #
  def __create_entries(schema)
    schema.map do |entry|
      entry[:chunks] = entry[:path][1..-1].split('/').reverse
      entry
    end
  end

  # Creates or updates the folder defined by these entries.
  # Then adds in any subfolders or subfiles
  def __parse_folder_entries(parent:, entries:, default_name: '')
    # find the info stream entry if it exists
    info = __read_info_entry(entries) || { name: default_name }
    # generate the folder path
    path = __build_path(entries)
    # create or update the folder
    folder = __build_folder(parent: parent, path: path, info: info)
    # group the folder entries
    groups = __group_entries(entries)
    # process the groups as subfolders or files
    __process_folder_contents(folder, groups)
    # return the updated folder
    folder
  end

  # if this folder has an info stream, find that entry and
  # use its metadata to update the folder's attributes
  def  __read_info_entry(entries)
    if entries[0][:chunks] == ['info']
      # if there is an info entry, remove it from the array
      # so we don't process it as a seperate file
      info_entry = entries.slice!(0)
      info_entry[:metadata]
    end
  end

  # all entries agree on a common path
  # up to the point where they still have
  # chunks. Get this common path by popping
  # the chunks off the first entry's path
  def __build_path(entries)
    parts = entries[0][:path].split('/')
    parts.pop(entries[0][:chunks].length)
    parts.join('/') # stitch parts together to form a path
  end

  # create or update a DbFolder object at the
  # specified path. If the parent parameter is nil
  # then the folder must be the Db's root folder
  def __build_folder(parent:, path:, info:)
    return @root_folder if parent.nil?
    folder = parent.subfolders.find_by_path(path)
    folder ||= DbFolder.new(parent: parent, path: path)
    folder.update_attributes(info)
    folder.save!
    folder
  end

  # collect the folder's entries into a set of groups
  # based off the next item in their :chunk array
  # returns entry_groups which is a Hash with
  # :key = name of the common chunk
  # :value = the entry, less the common chunk
  def __group_entries(entries)
    entry_groups = {}
    entries.map do |entry|
      # group streams by their base paths (ignore ~decim endings)
      group_name = entry[:chunks].pop.gsub(decimation_tag, '')
      __add_to_group(entry_groups, group_name, entry)
    end
    entry_groups
  end

  # regex matching the ~decimXX ending on a stream path
  def decimation_tag
    /~decim([\d]+)$/
  end

  # helper function to __group_entries that handles
  # sorting entries into the entry_groups Hash
  def __add_to_group(entry_groups, group_name, entry)
    entry_groups[group_name] ||= []
    if entry[:chunks] == ['info'] # put the info stream in front
      entry_groups[group_name].prepend(entry)
    else
      entry_groups[group_name].append(entry)
    end
  end

  # convert the groups into subfolders and files
  def __process_folder_contents(folder, groups)
    groups.each do |name, entry_group|
      if file?(entry_group)
        __build_file(folder: folder, entry_group: entry_group,
                     default_name: name)
      else # its a folder
        __parse_folder_entries(parent: folder, entries: entry_group,
                               default_name: name)
      end
    end
  end

  # determine if the entry groups constitute a single file
  def file?(entry_group)
    # if the path's are the same up to a ~decimXX suffix
    # this is a file, otherwise return false
    num_files = entry_group.map { |entry|
      entry[:path].gsub(decimation_tag, '')
    }.uniq.count
    num_files == 1
  end

  # create or update a DbFile object at the
  # specified path.
  def __build_file(folder:, entry_group:,
                   default_name:)
    base = __base_entry(entry_group)
    return unless base # corrupt file, don't process
    # find or create the file
    file = folder.db_files.find_by_path(base[:path])
    file ||= DbFile.new(db_folder: folder, path: base[:path])
    info = { name: default_name }.merge(base[:metadata])
    file.update_attributes(info)
    file.save!
    __build_decimations(file: file,
                        entry_group: entry_group - [base])
  end

  # find the base stream in this entry_group
  # this is the stream that doesn't have a decimXX tag
  # adds a warning and returns nil if base entry is missing
  def __base_entry(entry_group)
    base_entry = entry_group.select { |entry|
      entry[:path].match(decimation_tag).nil?
    }.first
    unless base_entry
      warnings << "Missing base stream for #{default_name} in #{folder.name}"
      return nil
    end
    base_entry
  end

  # create or update DbDecimations for the
  # specified DbFile
  def __build_decimations(file:, entry_group:)
    entry_group.each do |entry|
      level = entry[:path].match(decimation_tag)[1].to_i
      decim = file.db_decimations.find_by_level(level)
      decim ||= DbDecimation.new(db_file: file, level: level)
      decim.update_attributes(entry[:metadata])
      decim.save!
    end
  end
end
