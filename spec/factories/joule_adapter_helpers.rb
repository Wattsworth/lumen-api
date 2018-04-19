# frozen_string_literal: true

# Mock class to test clients
class MockJouleAdapter
  attr_reader :module_info
  def initialize
    @module_info = []
  end

  def add_module(name, inputs={}, outputs={})
    @module_info << {"name": name,
     "description": "mock module",
     "web_interface": true,
     "exec_cmd": "/path/to/cmd",
     "args": ["--message", "argval"],
     "input_paths": inputs,
     "output_paths": outputs,
     "status": "running",
     "pid": 26749,
     "id": 3,
     "socket": "/tmp/wattsworth.joule.2"}
  end
end
