# frozen_string_literal: true

# Agent class for DbFolders
class CreateNilm
  attr_accessor :errors, :warnings, :nilm

  def initialize
    @errors = []
    @warnings = []
  end

  def build(name:, url:, description: '')
    # create the NILM object
    @nilm = Nilm.new(name: name, url: url,
                     description: description)
    @nilm.save
    # create the database object and update it
    db = Db.create(nilm: @nilm)
    service = UpdateDb.new(db: db)
    adapter = DbAdapter.new(db.url)
    service.run(db_adapter: adapter)
  end
end
