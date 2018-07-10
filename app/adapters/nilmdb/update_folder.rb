# frozen_string_literal: true
module Nilmdb
  # Handles construction of DbFolder objects
  class UpdateFolder
    include ServiceStatus
    attr_reader :start_time, :end_time, :size_on_disk

    def initialize(folder, entries)
      @folder = folder
      @entries = entries
      # initialize extents, these are updated as folders/streams are added
      @start_time = nil
      @end_time = nil
      @size_on_disk = 0
      # initialiaze array of current entries, ids are removed
      # as they are updated, so any id's left in this
      # array are no longer present on the remote db
      # and will be destroyed
      @subfolder_ids = folder.subfolders.ids
      @stream_ids = folder.db_streams.ids
      super()
    end

    # returns the updated DbFolder object
    def run
      # update the folder attributes from metadata
      info = __read_info_entry(@entries) || {}
      # if metadata is corrupt, use default values instead
      unless @folder.update_attributes(
        info.slice(*DbFolder.defined_attributes))
        @folder.use_default_attributes
        Rails.logger.warn("corrupt metadata: #{@folder.path}")
      end
      # process the contents of the folder
      __parse_folder_entries(@folder, @entries)
      # delete any streams or folders still in the
      # tracked ID arrays, they haven't been touched
      # so they must have been removed from the remote
      # db some other way (eg nilmtool)
      unless @stream_ids.empty?
        @folder.db_streams.destroy(*@stream_ids)
        add_warning('Removed streams no longer in the remote database')
      end

      unless @subfolder_ids.empty?
        @folder.subfolders.destroy(*@subfolder_ids)
        add_warning('Removed folders no longer in the remote database')
      end
      # add the extents computed during updates
      @folder.start_time = @start_time
      @folder.end_time = @end_time
      @folder.size_on_disk = @size_on_disk
      # save the result
      unless @folder.valid?
        Rails.logger.warn("invalid folder: #{@folder.name}")
      end
      @folder.save!
      set_notice("Folder updated")
      self
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
      # so we don't process it as a seperate stream
      entries.delete(info_entry)
      # return the attributes
      info_entry[:attributes]
    end

    # Creates or updates the folder defined by these entries.
    # Then adds in any subfolders or streams
    def __parse_folder_entries(folder, entries)
      # group the folder entries
      groups = __group_entries(entries)
      # process the groups as subfolders or streams
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
        group_name = entry[:chunks].pop.gsub(UpdateStream.decimation_tag, '')
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

    # convert the groups into subfolders and streams
    def __process_folder_contents(folder, groups)
      groups.each do |name, entry_group|
        if stream?(entry_group)
          updater = __build_stream(folder, entry_group, name)
          next if updater.nil? # ignore orphaned decimations
        else # its a folder
          updater = __build_folder(folder, entry_group, name)
        end
        absorb_status(updater.run)
        absorb_data_extents(updater) # update start, end & size_on_disk
      end
    end

    # determine if the entry groups constitute a single stream
    def stream?(entry_group)
      # if any entry_group has chunks left, this is a folder
      entry_group.select { |entry|
        !entry[:chunks].empty?
      }.count.zero?
    end

    # create or update a DbStream object at the
    # specified path.
    def __build_stream(folder, entry_group,
                       default_name)
      base = __base_entry(entry_group)
      unless base # corrupt stream, don't process
        add_warning("#{entry_group.count} orphan decimations in #{folder.name}")
        return
      end
      # find or create the stream
      stream = folder.db_streams.find_by_path(base[:path])
      stream ||= DbStream.new(db: folder.db, db_folder: folder,
                              path: base[:path], name: default_name)
      # remove the id (if present) to mark this stream as updated
      @stream_ids -= [stream.id]
      # return the Updater, don't run it
      UpdateStream.new(stream, base, entry_group - [base])
    end

    # find the base stream in this entry_group
    # this is the stream that doesn't have a decimXX tag
    # adds a warning and returns nil if base entry is missing
    def __base_entry(entry_group)
      base_entry = entry_group.select { |entry|
        entry[:path].match(UpdateStream.decimation_tag).nil?
      }.first
      return nil unless base_entry
      base_entry
    end

    # create or update a DbFolder object at the
    # specified path.
    def __build_folder(parent, entries, default_name)
      path = __build_path(entries)
      folder = parent.subfolders.find_by_path(path)
      folder ||= DbFolder.new(parent: parent, db: parent.db,
                              path: path, name: default_name)
      # remove the id (if present) to mark this folder as updated
      @subfolder_ids -= [folder.id]
      # return the Updater, don't run it
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

    # update extents based on result of updater
    # (either a stream or a subfolder)
    def absorb_data_extents(updater)
      if @start_time.nil?
        @start_time = updater.start_time
      elsif !updater.start_time.nil?
        @start_time = [@start_time, updater.start_time].min
      end
      if @end_time.nil?
        @end_time = updater.end_time
      elsif !updater.end_time.nil?
        @end_time = [@end_time, updater.end_time].max
      end
      @size_on_disk += updater.size_on_disk
    end
  end
end