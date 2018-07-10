# frozen_string_literal: true

# Handles changing DbStream attributes
class EditStream
  include ServiceStatus

  def initialize(node_adapter)
    super()
    @node_adapter = node_adapter
  end

  def run(db_stream, attribs)
    # only accept valid attributes
    attribs.slice!(:name, :description, :name_abbrev, :hidden,
                   :db_elements_attributes)
    # assign the new attributes and check if the
    # result is valid (eg elements can't have the same name)
    db_stream.assign_attributes(attribs)
    unless db_stream.valid?
      db_stream.errors
               .full_messages
               .each { |e| add_error(e) }
      return self
    end
    # local model checks out, update the remote NilmDB
    status = @node_adapter.save_stream(db_stream)
    # if there was an error don't save the model
    if status[:error]
      add_error(status[:msg])
      return self
    end
    # everything went well, save the model
    db_stream.save!
    set_notice("Stream updated")
    self
  end

  def __parse_element_attribs(attribs)
    if !attribs.nil? && attribs.length>=1
      attribs.map { |element|
        {id: element[:id],
        name: element[:name]}
      }
    else
      []
    end
  end
end
