class JouleModulesController < ApplicationController
  before_action :authenticate_user!


  def show
    @joule_module = JouleModule.find(params[:id])
    @nilm = @joule_module.nilm
    head :unauthorized and return unless current_user.views_nilm?(@nilm)

    if(@joule_module.web_interface)
      @auth_token = InterfaceAuthToken.create(joule_module: @joule_module,
      user: current_user, expiration: 5.minutes.from_now)
    end
    render and return
  end


end
