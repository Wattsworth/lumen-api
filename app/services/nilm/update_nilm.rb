# frozen_string_literal: true

# Handles refreshing NILM's
class UpdateNilm
  include ServiceStatus

  def run(nilm)
    if nilm.db.nil?
      add_error('no associated db object')
      return self
    end
    db_adapter = DbAdapter.new(nilm.url)
    db_service = UpdateDb.new(db: nilm.db)
    absorb_status(
      db_service.run(db_adapter.dbinfo, db_adapter.schema)
    )
    joule_adapter = JouleAdapter.new(nilm.url)
    joule_module_service = UpdateJouleModules.new(nilm)
    absorb_status(
      joule_module_service.run(joule_adapter.module_info)
    )
    self
  end
end
