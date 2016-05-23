# frozen_string_literal: true

# Agent class for DbFolders
class CreateNilm
  attr_accessor :errors, :warnings, :nilm

  def initialize
    @errors = []
    @warnings = []
  end

  def build(name:, url:, description: '')
    @nilm = Nilm.new(name: name, url: url,
                     description: description)
    @nilm.save
    db = Db.create(nilm: @nilm)
    builder = DbBuilder.new(db: db)
    adapter = DbAdapter.new(db.url)
    builder.update_db(schema: adapter.schema)
  end
end
