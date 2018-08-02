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
      schema[:children].each do |child_schema|
        child = db_folder.subfolders.find_by_joule_id(child_schema[:id])
        child ||= DbFolder.new(parent: db_folder, db: db_folder.db)
        __update_folder(child, child_schema, db_folder.path)
        updated_ids << child_schema[:id]
      end
      # remove any subfolders that are no longer on the folder
      db_folder.subfolders.where.not(joule_id: updated_ids).destroy_all

      # update or create streams
      updated_ids=[]
      schema[:streams].each do |stream_schema|
        stream = db_folder.db_streams.find_by_joule_id(stream_schema[:id])
        stream ||= DbStream.new(db_folder: db_folder, db: db_folder.db)
        __update_stream(stream, stream_schema, db_folder.path)
        updated_ids << stream_schema[:id]
      end
      # remove any streams that are no longer in the folder
      db_folder.db_streams.where.not(joule_id: updated_ids).destroy_all
    end

    def __update_stream(db_stream, schema, parent_path)
      attrs = schema.slice(*DbStream.defined_attributes)
      # add in extra attributes that require conversion
      attrs[:path] = "#{parent_path}/#{schema[:name]}"
      attrs[:data_type] = "#{schema[:datatype].downcase}_#{schema[:elements].count}"
      attrs[:joule_id] = schema[:id]
      attrs[:total_time] = 100 # non-zero TODO, fix load_element so we don't need this
      db_stream.update_attributes(attrs)
      db_stream.db_elements.destroy_all
      schema[:elements].each do |element_config|
        attrs = element_config.slice(*DbElement.defined_attributes)
        # add in extra attributes that require conversion
        attrs[:display_type] = element_config[:display_type].downcase
        attrs[:column] = element_config[:index]
        attrs[:plottable] = true
        db_stream.db_elements << DbElement.new(attrs)
      end
    end


  end
end
