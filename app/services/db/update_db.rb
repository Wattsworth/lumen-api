# frozen_string_literal: true

# Handles construction of database objects
class UpdateDb
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

    updater = UpdateFolder.new(@root_folder, entries)
    updater.run()
    @errors << updater.errors
    @warnings << updater.warnings

    # parse the entries array
    # Note: @root_folder gets linked in on
    #       the first call to __build_folder
    # Don't save the result if there were errors
    if !@errors.empty?
      return false
    end
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

end
