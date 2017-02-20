# frozen_string_literal: true
class PermissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_nilm
  before_action :authorize_admin

  # GET /permissions
  # GET /permissions.json
  def index
    # return permissions for nilm specified by nilm_id
    @permissions = Permission.find_by_nilm(@nilm)
  end

  # POST /permissions
  # POST /permissions.json
  def create
    # create permission for nilm specified by nilm_id
    @service = PermissionService.new
    @service.run(@nilm, params[:role], params[:type], params[:target_id])
    @permission = @service.permission
    render status: @service.success? ? :ok : :unprocessable_entity
  end

  # DELETE /permissions/1
  # DELETE /permissions/1.json
  def destroy
    # remove permission from nilm specified by nilm_id
    @service = ServiceStub.new
    @service.add_notice("Removed permission")
    @nilm.permissions.find(params[:id]).destroy
  end

  private

  def set_nilm
    @nilm = Nilm.find(params[:nilm_id])
  end

  # authorization based on nilms
  def authorize_owner
    head :unauthorized  unless current_user.owns_nilm?(@nilm)
  end

end
