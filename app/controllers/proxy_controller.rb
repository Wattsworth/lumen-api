class ProxyController < ActionController::Base

  skip_before_action :verify_authenticity_token


  # /app/id.json is DataApp#show
  # /app/id/auth is authenticate
  # /proxy/id is proxied by nginx

  #GET /app/:id/auth
  def authenticate
    #if the user is already authenticated return the proxy url
    if params[:token].nil?
      if authenticate_interface_user
        response.set_header('X-PROXY-URL', @app.url)
        response.set_header('X-JOULE-KEY', @nilm.key)
        head :ok and return
      else
        head :forbidden and return
      end
    end
    # otherwise log them in and redirect to /proxy
    #reset_session
    token = InterfaceAuthToken.find_by_value(params[:token])
    render :unauthorized and return if token.nil?
    render :unauthorized and return if token.expiration < Time.now
    token.destroy
    session[:user_id]=token.user.id
    response.set_header('X-JOULE-KEY', token.data_app.nilm.key)

    redirect_to _app_proxy_url(token) and return
  end


  private

  def _app_proxy_url(token)
    #urls = Rails.application.config_for(:urls)
    #eg: http://3.interfaces.wattsworth.net/authenticate?token=1234
    Rails.configuration.app_proxy_url.call(token.data_app.id)
  end

  def authenticate_interface_user
    @current_user = User.find_by_id(session[:user_id])
    @app = DataApp.find_by_id(params[:id])
    @nilm = @app.nilm
    return false if @current_user.nil? || @app.nil?
    return false unless @current_user.views_nilm?(@nilm)
    true
  end

end
