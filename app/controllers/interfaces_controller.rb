class InterfacesController < ActionController::Base
  before_action :authenticate_interface_user!, except: [:authenticate]

  #GET /authenticate
  def authenticate
    token = InterfaceAuthToken.find(params[:token])
    #check if token timestamp is valid
    puts("this session is: #{session[:test]}")
    #sign_in(User.first)
    reset_session
    session[:user_id]=token.user.id
    session[:interface_id]=token.joule_module.id
    #interface_user_session(interface: token.interface.id)
    #redirect '/'
  end

  #GET /logout
  def logout
    interface_user_sign_out
  end

  #everything else is proxied
  private

  def authenticate_interface_user!
    puts 'authenticating...'
  end
end
