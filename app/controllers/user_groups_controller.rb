class UserGroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_group, only: [:update, :destroy]
  before_action :authentiate_group_admin, only: [:update, :destroy]

  # GET /user_groups.json
  def index
    @owned_groups = UserGroup.where(owner: current_user)
    @member_groups = current_user.user_groups
    my_groups = @member_groups+@owned_groups
    @other_groups = UserGroup.where.not(id: my_groups.pluck(:id))
  end

  # POST /user_groups.json
  def create
    @user_group = UserGroup.new(user_group_params)

    if @user_group.save
      render :show, status: :created, location: @user_group
    else
      render json: @user_group.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /user_groups/1
  # PATCH/PUT /user_groups/1.json
  def update
    if @user_group.update(user_group_params)
      render :show, status: :ok, location: @user_group
    else
      render json: @user_group.errors, status: :unprocessable_entity
    end
  end

  # DELETE /user_groups/1
  # DELETE /user_groups/1.json
  def destroy
    @user_group.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_group
      @user_group = UserGroup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_group_params
      params.permit(:name, :description)
    end

    def authorize_group_admin
      head :unauthorized unless @user_group.owner==current_user
    end
end
