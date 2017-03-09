class UsersController < ApplicationController
  before_action :authenticate_user!

  # GET /users.json
  def index
    @users = User.confirmed
  end

  # note: update is handled by devise

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
