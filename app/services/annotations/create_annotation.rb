# frozen_string_literal: true

class CreateAnnotation
  include ServiceStatus
  attr_reader :nilm

  def initialize(node_adapter)
    super()
    @node_adapter = node_adapter
  end

  def run(db_stream, annotation)
    status = @node_adapter.create_annotation(@annotation)
    # if there was an error don't save the model
    if status[:error]
      add_error(status[:msg])
      return self
    end
    add_warnings(msgs.errors + msgs.warnings)
    add_notice('Created annotation')
    self
  end
end
