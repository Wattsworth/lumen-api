# frozen_string_literal: true

# run method accepts any args
class MockServiceHelper
  include ServiceStatus

  def run(*_args, **_kwargs)
    self
  end
end
