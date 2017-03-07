RSpec::Matchers.define :have_error_message do |regex|
  match do |response|
    body = JSON.parse(response.body)
    # omit regex to test if there are any error messages
    if(regex == nil)
      return false if body["messages"]["errors"].empty?
      return true
    end
    # specify regex to match a particular error message
    body["messages"]["errors"].each do |error|
      return true if(regex.match(error))
    end
    return false
  end

  failure_message do |str|
    body = JSON.parse(response.body)
    "Expected #{regex} to match in [ " +
      body["messages"]["errors"].join(", ")+" ]"
  end

  failure_message_when_negated do |str|
    body = JSON.parse(response.body)
    "Expected #{regex} to not match in:\n" +
      body["messages"]["errors"].join(", ")
  end
end

RSpec::Matchers.define :have_warning_message do |regex|
  match do |response|
    body = JSON.parse(response.body)
    # omit regex to test if there are any warning messages
    if(regex == nil)
      return false if body["messages"]["warnings"].empty?
      return true
    end
    # specify regex to match a particular warning message
    body["messages"]["warnings"].each do |warning|
      return true if(regex.match(warning))
    end
    return false
  end

  failure_message do |str|
    body = JSON.parse(response.body)
    "Expected #{regex} to match in [ " +
      body["messages"]["warnings"].join(", ")+" ]"
  end

  failure_message_when_negated do |str|
    body = JSON.parse(response.body)
    "Expected #{regex} to not match in:\n" +
      body["messages"]["warnings"].join(", ")
  end
end

RSpec::Matchers.define :have_notice_message do |regex|
  match do |response|
    body = JSON.parse(response.body)
    # omit regex to test if there are any notice messages
    if(regex == nil)
      return false if body["messages"]["notices"].empty?
      return true
    end
    # specify regex to match a particular notice message
    body["messages"]["notices"].each do |notice|
      return true if(regex.match(notice))
    end
    return false
  end

  failure_message do |str|
    body = JSON.parse(response.body)
    "Expected #{regex} to match in [ " +
      body["messages"]["notices"].join(", ")+" ]"
  end

  failure_message_when_negated do |str|
    body = JSON.parse(response.body)
    "Expected #{regex} to not match in:\n" +
      body["messages"]["notices"].join(", ")
  end
end
