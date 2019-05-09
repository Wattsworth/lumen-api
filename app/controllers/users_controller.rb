class UsersController < ApplicationController
  before_action :authenticate_user!

  # GET /users.json
  def index
    #return all created or accepted users
    @users = User.where(invitation_created_at: nil)
      .or(User.where.not(invitation_accepted_at: nil))
  end

  # note: update is handled by devise

  # POST /users/auth_token.json
  def auth_token
    # To receive an auth token a user must be a current admin or there
    # are no NILM's associated with this node
    nilms = current_user.retrieve_nilms_by_permission
    head :unauthorized and return if (nilms[:admin].empty? and Nilm.count > 0)
    auth_key = NilmAuthKey.find_by_user_id(current_user.id)
    if auth_key.nil?
      auth_key = NilmAuthKey.create(user: current_user)
    end
    render json: {key: auth_key.key}
  end

  # POST /users.json
  def create
    @service = StubService.new
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def nilm_params
    params.permit(:first_name,
                  :last_name,
                  :email,
                  :password,
                  :password_confirmation)
  end

end
