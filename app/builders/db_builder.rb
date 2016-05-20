# frozen_string_literal: true

# Handles construction of database objects
class DbBuilder
  def initialize(db:, db_service:)
    @db = db
    @db_service = db_service
  end

  def update_db
    entries = @db_service.schema
    #split path into chunks
    entries.map! do |entry|
      entry[:chunks] = entry[:path][1..-1].split('/').reverse
      entry
    end
    if(@db.root_folder == nil)
      @db.root_folder=__build_folder(entries: entries, default_name: 'root')
    end
    #group entries by first chunk 
    #find or create an entry with the single chunk 'info'
    #if the group contains one entry that is *not* 'info', make it a file
    #if the group contains multiple entries, make it a folder
    #..recursive
  end
  
  protected
  
  def __build_folder(entries:, default_name:)
    folder = DbFolder.new(name: default_name)
    entry_groups = Hash.new()
    entries.map do |entry|
      __add_to_group(entry_groups, entry[:chunks].pop, entry)
    end
    entry_groups.each do |name, entry_group|
      if(entry_group.length==1)
        folder.db_files << __build_file(entry: entry_group, default_name: name)
      elsif(entry_group.length > 1)
        folder.subfolders << __build_folder(entries: entry_group, default_name: name)
      end
    end
    folder
  end
  
  def __add_to_group(entry_groups, group_name, entry)
    if entry_groups[group_name] == nil
      entry_groups[group_name] = [entry]
    else
      entry_groups[group_name].push(entry)
    end
  end
  
  
  def __build_file(entry:, default_name:)
    file = DbFile.new(name: default_name)
  end
end
