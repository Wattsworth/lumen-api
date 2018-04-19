require 'uri'

class JouleModulesController < ApplicationController
  before_action :authenticate_user!, only: [:show]
  before_action :authorize_viewer, only: [:show]

  # GET /joule_modules/<nilm_id>.json
  def show
    if(params[:refresh])
      adapter = JouleAdapter.new(@nilm.url)
      @service = UpdateJouleModules.new(@nilm)
      @service.run(adapter.module_info)
    else
      @service = StubService.new
    end
    @joule_modules = @nilm.joule_modules
    # create the unique URL for module proxy traffic
    @url_template = "http://%s.modules.wattsworth.local"
    render status: @service.success? ? :ok : :unprocessable_entity

  end

  private

  def authorize_viewer
    @nilm = Nilm.find(params[:id])
    head :unauthorized  unless current_user.views_nilm?(@nilm)
  end
end
