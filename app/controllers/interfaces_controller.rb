class InterfacesController < ActionController::Base
  before_action :authenticate_interface_user!, except: [:authenticate]
  before_action :create_adapter, only: [:get, :put, :post, :delete]

  after_action :allow_wattsworth_iframe
  #GET /authenticate
  def authenticate
    #if the user is already authenticated just destroy the token and redirect
    if _authenticate_interface_user
      token = InterfaceAuthToken.find_by_value(params[:token])
      token.destroy unless token.nil?
      redirect_to Rails.configuration.interface_url_template.call(@joule_module.id)
      return
    end
    # otherwise log them in
    reset_session
    token = InterfaceAuthToken.find_by_value(params[:token])
    render :unauthorized and return if token.nil?
    render :unauthorized and return if token.expiration < Time.now
    token.destroy
    session[:user_id]=token.user.id
    session[:interface_id]=token.joule_module.id
    redirect_to Rails.configuration.interface_url_template.call(token.joule_module.id)
  end

  #GET /logout
  def logout
    reset_session
    redirect_to Rails.configuration.interface_url_template.call(token.joule_module.id)
  end

  #everything else is proxied
  def get
    path = request.fullpath.sub("/api/interfaces/#{@joule_module.id}", "")
    proxied_response = @node_adapter.module_interface(@joule_module,path)

    render plain: proxied_response.body
    proxied_response.headers.each do |key,value|
      response.headers[key] = value
    end
  end

  def put
  end

  def post
    path = request.fullpath.sub("/api/interfaces/#{@joule_module.id}", "")
    proxied_response = @node_adapter.module_post_interface(@joule_module,path)

    render plain: proxied_response.body
    proxied_response.headers.each do |key,value|
      response.headers[key] = value
    end
  end

  def delete
  end

  private

  def authenticate_interface_user!
    render :unauthorized unless _authenticate_interface_user

    #verify the session matches the URL
    #verify the user has permissions on this module
  end

  def _authenticate_interface_user
    @current_user = User.find_by_id(session[:user_id])
    @joule_module = JouleModule.find_by_id(session[:interface_id])
    if @current_user.nil? || @joule_module.nil?
      return false
    end
    #@role = @current_user.module_role(@joule_module)
    #return false if @role.nil?
    true
  end

  def allow_wattsworth_iframe
    urls = Rails.application.config_for(:urls)
    # TODO: check if this does anything...
    response.headers['X-Frame-Options'] = "" #ALLOW-FROM #{urls['frontend']}"
  end

  def create_adapter
    nilm = @joule_module.nilm
    @node_adapter = NodeAdapterFactory.from_nilm(nilm)
    if @node_adapter.nil?
      @service = StubService.new
      @service.add_error("Cannot contact installation")
      render 'helpers/empty_response', status: :unprocessable_entity
    end
    if @node_adapter.node_type != 'joule'
      render 'helpers/empty_response', status: :unprocessable_entity
    end
  end
end
