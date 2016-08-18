# frozen_string_literal: true

# Handles construction of database objects
class UpdateDb
  include ServiceStatus

  def initialize(db:)
    @db = db
    super()
  end

  def run(schema)
    # create the root folder if it doesn't exist
    @db.root_folder ||= DbFolder.create(name: 'root', path: '/')
    @root_folder = @db.root_folder

    # create the entry array from the schema
    entries = __create_entries(schema)

    updater = UpdateFolder.new(@root_folder, entries)
    absorb_status(updater.run)

    @db.save
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
