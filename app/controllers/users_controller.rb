class UsersController < ApplicationController
  before_action :authenticate_user!

  # GET /users.json
  def index
    @users = User.confirmed
  end

end
