# frozen_string_literal: true

# Handles construction of DbFolder objects
class UpdateFolder
  attr_accessor :warnings, :errors

  def initialize(folder, entries)
    @folder = folder
    @entries = entries
    @warnings = []
    @errors = []
  end

  # returns the updated DbFolder object
  def run
    # update the folder attributes from metadata
    info = __read_info_entry(@entries) || {}
    @folder.update_attributes(
      info.slice(*DbFolder.defined_attributes))
    # process the contents of the folder
    __parse_folder_entries(@folder, @entries)
    # save the result
    @folder.save!
  end

  protected

  # if this folder has an info stream, find that entry and
  # use its metadata to update the folder's attributes
  def __read_info_entry(entries)
    info_entry = entries.detect do |entry|
      entry[:chunks] == ['info']
    end
    info_entry ||= {}
    # if there is an info entry, remove it from the array
    # so we don't process it as a seperate file
    entries.delete(info_entry)
    # return the attributes
    info_entry[:attributes]
  end

  # Creates or updates the folder defined by these entries.
  # Then adds in any subfolders or subfiles
  def __parse_folder_entries(folder, entries)
    # group the folder entries
    groups = __group_entries(entries)
    # process the groups as subfolders or files
    __process_folder_contents(folder, groups)
    # return the updated folder
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
      group_name = entry[:chunks].pop.gsub(UpdateFile.decimation_tag, '')
      __add_to_group(entry_groups, group_name, entry)
    end
    entry_groups
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
        updater = __build_file(folder, entry_group, name)
        next if updater.nil? # ignore orphaned decimations
      else # its a folder
        updater = __build_folder(folder, entry_group, name)
      end
      updater.run
      @warnings << updater.warnings
      @errors << updater.errors
    end
  end

  # determine if the entry groups constitute a single file
  def file?(entry_group)
    # if any entry_group has chunks left, this is a folder
    entry_group.select { |entry|
      !entry[:chunks].empty?
    }.count == 0
  end

  # create or update a DbFile object at the
  # specified path.
  def __build_file(folder, entry_group,
                   default_name)
    base = __base_entry(entry_group)
    unless base # corrupt file, don't process
      @warnings << "#{entry_group.count} orphan decimations in #{folder.name}"
      return
    end
    # find or create the file
    file = folder.db_files.find_by_path(base[:path])
    file ||= DbFile.new(db_folder: folder,
                        path: base[:path], name: default_name)

    UpdateFile.new(file, base, entry_group - [base])
  end

  # find the base stream in this entry_group
  # this is the stream that doesn't have a decimXX tag
  # adds a warning and returns nil if base entry is missing
  def __base_entry(entry_group)
    base_entry = entry_group.select { |entry|
      entry[:path].match(UpdateFile.decimation_tag).nil?
    }.first
    return nil unless base_entry
    base_entry
  end

  # create or update a DbFolder object at the
  # specified path.
  def __build_folder(parent, entries, default_name)
    path = __build_path(entries)
    folder = parent.subfolders.find_by_path(path)
    folder ||= DbFolder.new(parent: parent, path: path, name: default_name)
    UpdateFolder.new(folder, entries)
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
end
