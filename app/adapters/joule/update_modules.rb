# frozen_string_literal: true
module Joule
  # Handles construction of database objects
  class UpdateModules
    include ServiceStatus

    def initialize(nilm)
      super()
      @nilm = nilm
    end

    def run(module_schemas)
      #module_info as returned by JouleBackend
        if module_schemas.nil?
          add_error("unable to retrieve module information")
          return self
        end
        #remove the previous modules
        @nilm.joule_modules.destroy_all
        module_schemas.each do |schema|
          @nilm.joule_modules << _build_module(schema)
        end

        set_notice("refreshed modules")
        self
    end

    def _build_module(schema)
      # create JouleModule and associated pipes from
      # hash returned by the JouleAdapter.module_info
      attrs = schema.slice(*JouleModule.defined_attributes)
      attrs[:pid] = schema[:statistics][:pid]
      attrs[:web_interface] = schema[:is_app]
      attrs[:joule_id] = "m#{schema[:id]}"
      m = JouleModule.create(attrs)
      # link inputs to database streams
      schema[:inputs].each do |name, path|
        m.joule_pipes << JoulePipe.new(direction: 'input',
                                       name: name,
                                       db_stream: _retrieve_stream(path))
      end
      schema[:outputs].each do |name, path|
        m.joule_pipes << JoulePipe.new(direction: 'output',
                                       name: name,
                                       db_stream: _retrieve_stream(path))
      end
      m
    end

    def _retrieve_stream(path)
      db_stream = @nilm.db.db_streams.find_by_path(path)
      if db_stream.nil?
        add_warning("[#{path}] not in database")
      end
      db_stream
    end
  end
end
