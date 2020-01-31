class DataAppController < ApplicationController
  before_action :authenticate_user!

  # GET /app/:id.json
  def show
    @app = DataApp.find(params[:id])
    @nilm = @app.nilm
    head :unauthorized and return unless current_user.views_nilm?(@nilm)
    # destroy any existing tokens
    InterfaceAuthToken.where(user: current_user, data_app: @app).destroy_all

    @auth_url = _app_auth_url
    if @auth_url.nil?
      head :not_availble and return
    end
  end

  private

  def _app_auth_url
    # apps require a proxy server (like nginx)
    return nil unless
          request.headers.key?("HTTP_X_SUBDOMAIN_APPS")

    token = InterfaceAuthToken.create(data_app: @app,
                                      user: current_user,
                                      expiration: 5.minutes.from_now)
    # proxy supports subdomains (preferred because more secure and flexible)
    if request.headers["HTTP_X_SUBDOMAIN_APPS"] == 'true'
      server = request.headers["HTTP_X_APP_SERVER_NAME"]
      scheme = request.headers["HTTP_X_APP_SERVER_SCHEME"]
      "#{scheme}://#{token.data_app.id}.app.#{server}?auth_token=#{token.value}"
    # fall back on hosting apps relative to the base url
    else
      base = request.headers["HTTP_X_APP_BASE_URI"]
      "#{base}/#{token.data_app.id}/?auth_token=#{token.value}"
    end
  end
end
