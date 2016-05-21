# frozen_string_literal: true

# Handles construction of database objects
class DbBuilder
  def initialize(db:)
    @db = db
  end

  def update_db(schema:)
    # split path into chunks
    entries = schema.map do |entry|
      entry[:chunks] = entry[:path][1..-1].split('/').reverse
      entry
    end
    # create the root folder if it doesn't exist
    @db.root_folder ||= DbFolder.create(name: 'root', path: '/')
    @root_folder = @db.root_folder
    # add the folder entries
    __parse_folder_entries(parent: nil, entries: entries)
  end

  protected

  def __parse_folder_entries(parent:, entries:, default_name: '')
    # find the info stream entry if it exists
    info = __read_info_entry(entries) || { name: default_name }
    # generate the folder path
    path = __build_path(entries)
    # create or update the folder
    folder = __build_folder(parent: parent, path: path, info: info)
    # group the folder entries
    groups = __group_entries(entries)
    # convert the entries into subfolders and files
    groups.each do |name, entry_group|
      if entry_group.length == 1
        folder.db_files << __build_file(folder: folder, entry: entry_group[0],
                                        default_name: name)
      elsif entry_group.length > 1
        folder.subfolders << __parse_folder_entries(parent: folder,
                                                    entries: entry_group,
                                                    default_name: name)
      end
    end
    folder
  end

  def  __read_info_entry(entries)
    if entries[0][:chunks] == ['info']
      info_entry = entries.slice!(0)
      info_entry[:metadata]
    end
  end

  def __build_folder(parent:, path:, info:)
    return @root_folder if parent.nil?
    folder = parent.subfolders.find_by_path(path)
    folder ||= DbFolder.new(parent: parent, path: path)
    folder.update_attributes(info)
    folder.save!
    folder
  end

  def __build_file(folder:, entry:, default_name:)
    file = folder.db_files.find_by_path(entry[:path])
    file ||= DbFile.new(name: default_name)
    file.save!
    file
  end

  def __build_path(entries)
    # all entries agree on a common path
    # up to the point where they still have
    # chunks. Get this common path by popping
    # the chunks off the first entry's path
    parts = entries[0][:path].split('/')
    parts.pop(entries[0][:chunks].length)
    parts.join('/') # stitch parts together to form a path
  end

  def __group_entries(entries)
    entry_groups = {}
    entries.map do |entry|
      __add_to_group(entry_groups, entry[:chunks].pop, entry)
    end
    entry_groups
  end

  def __add_to_group(entry_groups, group_name, entry)
    entry_groups[group_name] ||= []
    if entry[:chunks] == ['info'] # put the info stream in front
      entry_groups[group_name].prepend(entry)
    else
      entry_groups[group_name].append(entry)
    end
  end
end
