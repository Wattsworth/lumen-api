# frozen_string_literal: true

# Handles service errors and warnings. Design pattern:
# All service action should occur in the run() function
# Within run, call add_error or add_warning with string
# messages. At the end of run() return the service object itself
# For nested services, call absorb_service(child.run()) to nest
# the errors and warnings of the child into the parent, set
# the action parameter to NEVER_FAIL, FAIL_ON_WARNING, or
# FAIL_ON_ERROR to determine when (if ever), absorb_status
# returns false
module ServiceStatus
  attr_reader :errors, :warnings

  FAIL_ON_ERROR   = 0
  FAIL_ON_WARNING = 1
  NEVER_FAIL      = 2

  def initialize
    @errors = []
    @warnings = []
  end

  def add_error(message)
    @errors << String(message)
  end

  def errors?
    !@errors.empty?
  end

  def add_warning(message)
    @warnings << String(message)
  end

  def warnings?
    !@warnings.empty?
  end

  def run
    raise 'Implement in client, return service object'
  end

  def absorb_status(service, action: FAIL_ON_ERROR)
    @warnings += service.warnings
    @errors += service.errors
    case action
    when FAIL_ON_WARNING
      return false if warnings? || errors?
    when FAIL_ON_ERROR
      return false if errors?
    end
    true
  end
end
