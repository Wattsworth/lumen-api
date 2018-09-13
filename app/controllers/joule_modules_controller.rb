class JouleModulesController < ApplicationController
  before_action :authenticate_user!


  def show
    @joule_module = JouleModule.find(params[:id])
    @nilm = @joule_module.nilm
    head :unauthorized and return unless current_user.views_nilm?(@nilm)

    if @joule_module.web_interface
      token = InterfaceAuthToken.create(joule_module: @joule_module,
      user: current_user, expiration: 5.minutes.from_now)
      @module_url = _interface_authentication_url(token)
    end
    render and return
  end

  private

  def _interface_authentication_url(token)
    #urls = Rails.application.config_for(:urls)
    #eg: http://3.interfaces.wattsworth.net/authenticate?token=1234
    Rails.configuration.interface_url_template.call(
        token.joule_module.id)+"/authenticate?token="+token.value
  end

end
