# frozen_string_literal: true

# controller for NILM objects
class NilmsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_nilm, only: [:show, :update]
  before_action :authorize_viewer, only: [:show]
  before_action :authorize_owner, only: [:update]

  # GET /nilms
  # GET /nilms.json
  def index
    @nilms = current_user.retrieve_nilms_by_permission
  end

  # GET /nilms/1
  # GET /nilms/1.json
  def show
    # renders nilms/show
  end

  # PATCH/PUT /nilms/1
  # PATCH/PUT /nilms/1.json
  def update
    @service = StubService.new
    if @nilm.update(nilm_params)
      @service.add_notice('NILM Updated')
      render status: :ok
    else
      @service.errors = @nilm.errors.full_messages
      render status: :unprocessable_entity
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_nilm
      @nilm = Nilm.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def nilm_params
      params.permit(:name, :description,:url)
    end

    #authorization based on nilms
    def authorize_owner
      head :unauthorized  unless current_user.owns_nilm?(@nilm)
    end
    def authorize_viewer
      head :unauthorized  unless current_user.views_nilm?(@nilm)
    end
end
