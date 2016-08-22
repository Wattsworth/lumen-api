# frozen_string_literal: true

# Handles changing DbFolder attributes
class EditFolder
  include ServiceStatus

 def initialize(db_adapter)
    super()
  end

  def run(db_file, *attribs)
    # only accept valid attributes
    attribs.slice!([:name, :description])
    # assign the new attributes and check if the 
    # result is valid (eg file's can't have the same name)
    db_file.assign_attributes(attribs)
    unless db_file.valid?
      add_error(db_file.errors)
      return self
    end
    # local model checks out, update the remote NilmDB
    db_adapter.update_metadata(db_file.path,
                               attribs.filter { |x| x.in[:name, :description] } )
    # if there was an error don't save the model
    if db_adapter.status == ERROR:
      add_error(db_adapter.error_msg)
      return self
    end
    # everything went well, save the model
    db_file.save!
    self
  end

end