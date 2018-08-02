# frozen_string_literal: true

# Handles refreshing NILM's
class UpdateNilm
  include ServiceStatus

  def initialize(node_adapter)
    super()
    @node_adapter = node_adapter
  end
  def run(nilm)
    if nilm.db.nil?
      add_error('no associated db object')
      return self
    end
    absorb_status(@node_adapter.refresh(nilm))
    self
  end
end
