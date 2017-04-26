# frozen_string_literal: true

# Handles construction of database objects
class UpdateDb
  include ServiceStatus

  def initialize(db:)
    @db = db
    super()
  end

  def run(dbinfo, schema)
    # check to make sure dbinfo and schema are set
    # if either is nil, the database is not available
    if(dbinfo.nil? || schema.nil?)
      add_error("cannot contact database at #{@db.url}")
      @db.update_attributes(available: false)
      return self
    else
      @db.available = true
    end

    # create the root folder if it doesn't exist
    @db.root_folder ||= DbFolder.create(db: @db, name: 'root', path: '/')
    @root_folder = @db.root_folder

    # create the entry array from the schema
    entries = __create_entries(schema)

    updater = UpdateFolder.new(@root_folder, entries)
    # update db attributes from dbinfo
    @db.size_total = dbinfo[:size_total]
    @db.size_db = dbinfo[:size_db]
    @db.size_other = dbinfo[:size_other]
    @db.version = dbinfo[:version]
    absorb_status(updater.run)

    @db.save
    set_notice("Database refreshed")
    self
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
end
