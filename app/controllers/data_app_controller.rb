class DataAppController < ApplicationController
  before_action :authenticate_user!

  def show
    @app = DataApp.find(params[:id])
    @nilm = @app.nilm
    head :unauthorized and return unless current_user.views_nilm?(@nilm)


    token = InterfaceAuthToken.create(data_app: @app,
                                      user: current_user, expiration: 5.minutes.from_now)
    @auth_url = _app_auth_url(token)
  end

  private

  def _app_auth_url(token)
    #urls = Rails.application.config_for(:urls)
    #eg: http://3.interfaces.wattsworth.net/authenticate?token=1234
    Rails.configuration.app_auth_url.call(
        token.data_app.id)+"?token="+token.value
  end

  def authenticate_interface_user
    @current_user = User.find_by_id(session[:user_id])
    @app = DataApp.find_by_id(session[:interface_id])
    if @current_user.nil? || @app.nil?
      return false
    end
    true
  end

end
