class InterfacesController < ActionController::Base
  before_action :authenticate_interface_user!, except: [:authenticate]

  #GET /authenticate
  def authenticate
    reset_session
    token = InterfaceAuthToken.find_by_id(params[:token])
    render :unauthorized and return if token.nil?
    render :unauthorized and return if token.expiration < Time.now
    token.destroy
    session[:user_id]=token.user.id
    session[:interface_id]=token.joule_module.id
    render plain: "welcome #{token.user.email}"
  end

  #GET /logout
  def logout
    reset_session
    redirect '/'
  end

  #everything else is proxied
  def get
    render 'ok, you got it'
  end

  def put
  end

  def post
  end

  def delete
  end

  private

  def authenticate_interface_user!
    @current_user = User.find_by_id(session[:user_id])
    render :unauthorized if @current_user.nil?
    #verify the session matches the URL
    #verify the user has permissions on this module

  end
end
