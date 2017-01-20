# frozen_string_literal: true

# Handles changing DbFolder attributes
class EditFolder
  include ServiceStatus

  def initialize(db_adapter)
    super()
    @db_adapter = db_adapter
  end

  def run(db_folder, **attribs)
    # only accept valid attributes
    attribs.slice!(:name, :description, :hidden)
    # assign the new attributes and check if the
    # result is valid (eg folder's can't have the same name)
    db_folder.assign_attributes(attribs)
    unless db_folder.valid?
      db_folder.errors
        .full_messages
        .each{|e| add_error(e)}
      return self
    end
    # local model checks out, update the remote NilmDB
    status = @db_adapter.set_folder_metadata(db_folder)
    # if there was an error don't save the model
    if status[:error]
      add_error(status[:msg])
      return self
    end
    # everything went well, save the model
    db_folder.save!
    self
  end
end
