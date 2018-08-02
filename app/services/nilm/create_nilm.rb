# frozen_string_literal: true

# Agent class for DbFolders
class CreateNilm
  include ServiceStatus
  attr_reader :nilm

  def initialize(node_adapter)
    super()
    @node_adapter = node_adapter
  end

  def run(name:, url:, owner:, description:'')
    # note: url should be NilmDB url
    @nilm = Nilm.new(name: name,
                     description: description,
                     url: url,
                     node_type: @node_adapter.node_type)
    unless @nilm.valid?
      add_errors(@nilm.errors.full_messages)
      return self
    end

    # create the database object and update it
    # pass NILM url onto database since we are using
    # a single endpoint (eventually this will be joule)
    db = Db.new(nilm: @nilm, url: url)
    unless db.valid?
      add_errors(db.errors.full_messages.map{|msg| "Database: #{msg}"})
      return self
    end
    #everything is valid, save the objects
    nilm.save
    db.save
    #give the owner 'admin' permissions on the nilm
    Permission.create(user: owner, nilm: nilm, role: 'admin')
    #update the database
    msgs = @node_adapter.refresh(nilm)
    #errors on the database update are warnings on this service
    #because we can still add the NILM, it will just be offline
    add_warnings(msgs.errors + msgs.warnings)
    add_notice('Created installation')
    self
  end
end
