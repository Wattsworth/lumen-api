# frozen_string_literal: true
module Joule
  # Handles construction of database objects
  class UpdateDb
    include ServiceStatus

    def initialize(db)
      @db = db
      super()
    end

    def run(dbinfo, schema)
      # check to make sure dbinfo and schema are set
      # if either is nil, the database is not available
      if dbinfo.nil? || schema.nil?
        add_error("cannot contact database at #{@db.url}")
        @db.update_attributes(available: false)
        return self
      end
      # go through the schema and update the database
      @db.root_folder ||= DbFolder.create(db: @db)
      __update_folder(@db.root_folder, schema, '')
      @db.available = true
      @db.save
      self
    end

    def __update_folder(db_folder, schema, parent_path)
      attrs = schema.slice(*DbFolder.defined_attributes)
      # add in extra attributes that require conversion
      if db_folder.parent.nil?
        attrs[:path] = ""
      else
        attrs[:path] = "#{parent_path}/#{schema[:name]}"
      end
      attrs[:joule_id] = schema[:id]
      attrs[:hidden] = false
      db_folder.update_attributes(attrs)
      #puts db_folder.parent.id
      # update or create subfolders
      updated_ids = []
      size_on_disk = 0
      start_time = nil
      end_time = nil
      locked = false
      schema[:children].each do |child_schema|
        child = db_folder.subfolders.find_by_joule_id(child_schema[:id])
        child ||= DbFolder.new(parent: db_folder, db: db_folder.db)
        __update_folder(child, child_schema, db_folder.path)
        size_on_disk+=child.size_on_disk
        unless child.start_time.nil?
          if start_time.nil?
            start_time = child.start_time
          else
            start_time = [child.start_time, start_time].min
          end
        end
        unless child.end_time.nil?
          if end_time.nil?
            end_time = child.end_time
          else
            end_time = [child.end_time, end_time].max
          end
        end
        updated_ids << child_schema[:id]
        locked = true if child.locked?
      end
      # remove any subfolders that are no longer on the folder
      db_folder.subfolders.where.not(joule_id: updated_ids).destroy_all

      # update or create streams
      updated_ids=[]
      schema[:streams].each do |stream_schema|
        stream = db_folder.db_streams.find_by_joule_id(stream_schema[:id])
        stream ||= DbStream.new(db_folder: db_folder, db: db_folder.db)
        __update_stream(stream, stream_schema, db_folder.path)
        size_on_disk+=stream.size_on_disk
        unless stream.start_time.nil?
          if start_time.nil?
            start_time = stream.start_time
          else
            start_time = [stream.start_time, start_time].min
          end
        end
        unless stream.end_time.nil?
          if end_time.nil?
            end_time = stream.end_time
          else
            end_time = [stream.end_time, end_time].max
          end
        end
        locked=true if stream.locked?
        updated_ids << stream_schema[:id]
      end
      # remove any streams that are no longer in the folder
      db_folder.db_streams.where.not(joule_id: updated_ids).destroy_all
      # save the new disk size
      db_folder.size_on_disk = size_on_disk
      db_folder.start_time = start_time
      db_folder.end_time = end_time
      db_folder.locked = locked
      db_folder.save
    end

    def __update_stream(db_stream, schema, parent_path)
      attrs = schema.slice(*DbStream.defined_attributes)
      # add in extra attributes that require conversion
      attrs[:path] = "#{parent_path}/#{schema[:name]}"
      attrs[:data_type] = "#{schema[:datatype].downcase}_#{schema[:elements].count}"
      attrs[:joule_id] = schema[:id]
      attrs[:start_time] = schema[:data_info][:start]
      attrs[:end_time] = schema[:data_info][:end]
      attrs[:total_rows] = schema[:data_info][:rows]
      attrs[:total_time] = schema[:data_info][:total_time]
      attrs[:size_on_disk] = schema[:data_info][:bytes]

      db_stream.update_attributes(attrs)
      #db_stream.db_elements.destroy_all
      schema[:elements].each do |element_config|
        element = db_stream.db_elements.find_by_column(element_config[:index])
        element ||= DbElement.new(db_stream: db_stream)
        attrs = element_config.slice(*DbElement.defined_attributes)
        # add in extra attributes that require conversion
        attrs[:display_type] = element_config[:display_type].downcase
        attrs[:column] = element_config[:index]
        attrs[:plottable] = true
        element.update_attributes(attrs)
      end
    end


  end
end
