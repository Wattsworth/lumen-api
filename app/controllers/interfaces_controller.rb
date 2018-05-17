class InterfacesController < ActionController::Base
  before_action :authenticate_interface_user!, except: [:authenticate]
  after_action :allow_wattsworth_iframe
  #GET /authenticate
  def authenticate
    puts "here we go!"
    reset_session
    token = InterfaceAuthToken.find_by_value(params[:token])
    render :unauthorized and return if token.nil?
    render :unauthorized and return if token.expiration < Time.now
    token.destroy
    session[:user_id]=token.user.id
    session[:interface_id]=token.joule_module.id
    redirect_to '/'
  end

  #GET /logout
  def logout
    reset_session
    redirect_to '/'
  end

  #everything else is proxied
  def get
    path = params[:path] || ''
    req = path +"?"+request.query_string
    adapter = JouleAdapter.new(@joule_module.nilm.url)
    render plain: adapter.module_interface(@joule_module,req)
  end

  def put
  end

  def post
  end

  def delete
  end

  private

  def authenticate_interface_user!
    puts "trying to figure out the users..."
    @current_user = User.find_by_id(session[:user_id])
    @joule_module = JouleModule.find_by_id(session[:interface_id])
    render :unauthorized if (@current_user.nil? || @joule_module.nil?)
    #verify the session matches the URL
    #verify the user has permissions on this module
  end

  def allow_wattsworth_iframe
    urls = Rails.application.config_for(:urls)
    # TODO: check if this does anything...
    response.headers['X-Frame-Options'] = "ALLOW-FROM #{urls['frontend']}"
  end

end
