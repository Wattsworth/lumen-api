# frozen_string_literal: true

# Handles changing DbStream attributes
class EditEventStream
  include ServiceStatus

  def initialize(node_adapter)
    super()
    @node_adapter = node_adapter
  end

  def run(event_stream, attribs)
    # only accept valid attributes
    attribs.slice!(:name, :description)
    # assign the new attributes and check if the
    # result is valid (eg elements can't have the same name)
    event_stream.assign_attributes(attribs)
    unless event_stream.valid?
      event_stream.errors
          .full_messages
          .each { |e| add_error(e) }
      return self
    end
    # local model checks out, update the remote Joule
    status = @node_adapter.save_event_stream(event_stream)
    # if there was an error don't save the model
    if status[:error]
      add_error(status[:msg])
      return self
    end
    # everything went well, save the model
    event_stream.save!
    set_notice("Stream updated")
    self
  end
end
