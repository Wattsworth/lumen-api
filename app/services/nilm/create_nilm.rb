# frozen_string_literal: true

# Agent class for DbFolders
class CreateNilm
  attr_accessor :errors, :warnings, :nilm

  def initialize
    @errors = []
    @warnings = []
  end

  def run(name:, url:, description: '', db_url: '')
    # create the NILM object
    @nilm = Nilm.new(name: name, url: url,
                     description: description)
    @nilm.save
    # create the database object and update it
    db = Db.create(nilm: @nilm, url: db_url)
    service = UpdateDb.new(db: db)
    adapter = DbAdapter.new(db.url)
    service.run(adapter.schema)
  end
end
