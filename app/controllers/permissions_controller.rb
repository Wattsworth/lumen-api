# frozen_string_literal: true
class PermissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_nilm
  before_action :authorize_admin

  # GET /permissions
  # GET /permissions.json
  def index
    # return permissions for nilm specified by nilm_id
    @permissions = @nilm.permissions
  end

  # POST /permissions
  # POST /permissions.json
  def create
    # create permission for nilm specified by nilm_id
    @service = CreatePermission.new
    @service.run(@nilm, params[:role], params[:target], params[:target_id])
    @permission = @service.permission
    render status: @service.success? ? :ok : :unprocessable_entity
  end

  # DELETE /permissions/1
  # DELETE /permissions/1.json
  def destroy
    # remove permission from nilm specified by nilm_id
    @service = DestroyPermission.new
    @service.run(@nilm, current_user, params[:id])
    render status: @service.success? ? :ok : :unprocessable_entity
  end

  private

  def set_nilm
    @nilm = Nilm.find_by_id(params[:nilm_id])
    head :not_found unless @nilm
  end

  # authorization based on nilms
  def authorize_admin
    head :unauthorized  unless current_user.admins_nilm?(@nilm)
  end

end
