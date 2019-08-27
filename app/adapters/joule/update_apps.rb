# frozen_string_literal: true
module Joule
  # Handles construction of database objects
  class UpdateApps
    include ServiceStatus

    def initialize(nilm)
      super()
      @nilm = nilm
    end

    def run(app_schemas)
      if app_schemas.nil?
        add_error("unable to retrieve app information")
        return self
      end

      #remove the previous modules
      @nilm.data_apps.destroy_all
      app_schemas.each do |schema|
        @nilm.data_apps << DataApp.new(name: schema[:name],
                                       joule_id: schema[:id])
      end
      set_notice("refreshed apps")
      self

    end
  end

end