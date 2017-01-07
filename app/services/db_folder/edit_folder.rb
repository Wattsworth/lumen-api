# frozen_string_literal: true

# Handles changing DbFolder attributes
class EditFolder
  include ServiceStatus

  def initialize(db_adapter)
    super()
    @db_adapter = db_adapter
  end

  def run(db_stream, **attribs)
    # only accept valid attributes
    attribs.slice!([:name, :description])
    # assign the new attributes and check if the
    # result is valid (eg stream's can't have the same name)
    db_stream.assign_attributes(attribs)
    unless db_stream.valid?
      add_error(db_stream.errors)
      return self
    end
    # local model checks out, update the remote NilmDB
    @db_adapter.update_metadata(db_stream.path, attribs)
    # if there was an error don't save the model
    if db_adapter.status == ERROR
      add_error(db_adapter.error_msg)
      return self
    end
    # everything went well, save the model
    db_stream.save!
    self
  end
end
