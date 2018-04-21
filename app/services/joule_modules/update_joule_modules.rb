# frozen_string_literal: true

# Handles construction of database objects
class UpdateJouleModules
  include ServiceStatus

  def initialize(nilm)
    super()
    @nilm = nilm
  end

  def run(module_info)
    #module_info as returned by JouleAdapter
      if module_info.nil?
        add_error("unable to retrieve module information")
        return self
      end
      #remove the previous modules
      @nilm.joule_modules.destroy_all
      module_info.each do |info|
        @nilm.joule_modules << _build_module(info)
      end

      set_notice("refreshed modules")
      self
  end

  def _build_module(info)
    # create JouleModule and associated pipes from
    # hash returned by the JouleAdapter.module_info
    params = info.extract!(*JouleModule.joule_keys)
    m = JouleModule.new(params)
    # link inputs to database streams
    info[:input_paths].each do |name, path|
      m.joule_pipes << JoulePipe.new(direction: 'input',
                                     name: name,
                                     db_stream: _retrieve_stream(path))
    end
    info[:output_paths].each do |name, path|
      m.joule_pipes << JoulePipe.new(direction: 'output',
                                     name: name,
                                     db_stream: _retrieve_stream(path))
    end
    return m
  end

  def _retrieve_stream(path)
    dbStream = @nilm.db.db_streams.find_by_path(path)
    if dbStream.nil?
      add_warning("[#{path}] not in database")
    end
    dbStream
  end
end
