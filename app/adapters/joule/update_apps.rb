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

      #keep track of apps that already loaded
      old_app_ids = @nilm.data_apps.map{|app| app.id}
      app_schemas.each do |schema|
        cur_app =  @nilm.data_apps.where(name: schema[:name], joule_id: schema[:id]).first
        if cur_app.nil?
          @nilm.data_apps << DataApp.new(name: schema[:name],
                                         joule_id: schema[:id])
        else
          old_app_ids.delete(cur_app.id)
        end
      end
      DataApp.destroy(old_app_ids)
      set_notice("refreshed apps")
      self

    end
  end

end