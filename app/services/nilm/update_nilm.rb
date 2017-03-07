# frozen_string_literal: true

# Handles refreshing NILM's
class UpdateNilm
  include ServiceStatus

  def run(nilm)
    if nilm.db.nil?
      add_error('no associated db object')
      return self
    end
    adapter = DbAdapter.new(nilm.url)
    service = UpdateDb.new(db: nilm.db)
    absorb_status(
      service.run(adapter.dbinfo, adapter.schema)
    )
    self
  end
end
