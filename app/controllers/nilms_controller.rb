# frozen_string_literal: true

# controller for NILM objects
class NilmsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_nilm, only: [:update, :show, :refresh, :destroy]
  before_action :authorize_viewer, only: [:show]
  before_action :authorize_owner, only: [:update, :refresh]
  before_action :authorize_admin, only: [:destroy]
  before_action :create_adapter, only: [:create]

  # GET /nilms.json
  def index
    #just the NILM info, no database or joule modules
    @nilms = current_user.retrieve_nilms_by_permission
  end

  def show
    #render the database and joule modules
    @role = current_user.get_nilm_permission(@nilm)
    #request new information from the NILM
    if params[:refresh]
      @service = UpdateNilm.new(@adapter)
      @service.run(@nilm)
      render status: @service.success? ? :ok : :unprocessable_entity
    else
      @service = StubService.new
    end
  end

  # POST /nilms.json
  def create
    @service = CreateNilm.new(@node_adapter)
    @service.run(name: nilm_params[:name],
                 url: nilm_params[:url],
                 description: nilm_params[:description],
                 owner: current_user)
    @nilm = @service.nilm
    @role = 'owner'
    render :show, status: @service.success? ? :ok : :unprocessable_entity
  end

  # PATCH/PUT /nilms/1
  # PATCH/PUT /nilms/1.json
  def update
    #update both the NILM and the Db models
    @service = StubService.new
    # redundant since the user must be an owner...
    @role = current_user.get_nilm_permission(@nilm)
    if @nilm.update(nilm_params) && @db.update(db_params)
      @service.add_notice('Installation Updated')
      render :show, status: :ok
    else
      @service.errors = @nilm.errors.full_messages +
                        @db.errors.full_messages
      render :show, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /nilms/1/refresh.json
  def refresh

  end

  # DELETE /nilms/1.json
  def destroy
    @service = StubService.new
    @nilm.destroy
    @service.set_notice('removed nilm')
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_nilm
      @nilm = Nilm.find(params[:id])
      @db = @nilm.db
      @adapter = Nilmdb::Adapter.new(@nilm.url)
    end

    # Never trust parameters from the scary internet,
    # only allow the white list through.
    def nilm_params
      params.permit(:name, :description, :url)
    end
    def db_params
      params.permit(:max_points_per_plot)
    end

    #authorization based on nilms
    def authorize_admin
      head :unauthorized  unless current_user.admins_nilm?(@nilm)
    end
    def authorize_owner
      head :unauthorized  unless current_user.owns_nilm?(@nilm)
    end
    def authorize_viewer
      head :unauthorized  unless current_user.views_nilm?(@nilm)
    end

    def create_adapter
      @node_adapter = NodeAdapterFactory.from_url(nilm_params[:url])
      if @node_adapter.nil?
        @service = StubService.new
        @service.add_error("Cannot contact installation")
        render 'helpers/empty_response', status: :unprocessable_entity
      end
    end
end
