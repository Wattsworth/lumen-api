# frozen_string_literal: true

# No run method, just implements messages
# used by controllers that need to return messsages but do not
# run a service (eg a simple update)
class StubService
  include ServiceStatus
end
