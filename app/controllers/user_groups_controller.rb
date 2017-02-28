# frozen_string_literal: true
class UserGroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_group,
                only: [:update,
                       :remove_member,
                       :add_member,
                       :destroy]
  before_action :authorize_group_admin,
                only: [:update,
                       :remove_member,
                       :add_member,
                       :destroy]

  # GET /user_groups.json
  def index
    @owned_groups = UserGroup.where(owner: current_user)
    @member_groups = current_user.user_groups
    my_groups = @member_groups + @owned_groups
    @other_groups = UserGroup.where.not(id: my_groups.pluck(:id))
  end

  # POST /user_groups.json
  def create
    @user_group = UserGroup.create(user_group_params)
    @user_group.owner = current_user
    @service = StubService.new
    if @user_group.save
      @service.add_notice('created new group')
      render :show, status: :ok
    else
      @service.errors = @user_group.errors.full_messages
      render :show, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /user_groups/1/add_member.json
  def add_member
    @service = AddGroupMember.new
    @service.run(@user_group, params[:user_id])
    render :show, status: @service.success? ? :ok : :unprocessable_entity
  end

  # PATCH/PUT /user_groups/1/remove_member.json
  def remove_member
    @service = RemoveGroupMember.new
    @service.run(@user_group, params[:user_id])
    render :show, status: @service.success? ? :ok : :unprocessable_entity
  end

  # PATCH/PUT /user_groups/1.json
  def update
    # TODO
  end

  # DELETE /user_groups/1.json
  def destroy
    @service = StubService.new
    @user_group.destroy
    @service.set_notice('removed group')
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
    head :unauthorized unless @user_group.owner == current_user
  end
end
