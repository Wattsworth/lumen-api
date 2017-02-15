# frozen_string_literal: true

# Controller for Database Objects
class DbsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_db, only: [:show, :update]
  before_action :authorize_viewer, only: [:show]
  before_action :authorize_owner, only: [:update]

  # GET /dbs
  # GET /dbs.json
  def show
    db = Db.find(params[:id])
    head(:unauthorized) && return unless current_user.views_nilm?(db.nilm)
    render json: db
  end

  # PATCH/PUT /dbs/1
  # PATCH/PUT /dbs/1.json
  def update
    @service = StubService.new
    prev_url = @db.url
    if @db.update_attributes(db_params)
      if prev_url != @db.url || params[:refresh]
        # refresh the database
        @service = refresh
        render status: @service.success? ? :ok : :unprocessable_entity
      else
        @service.add_notice('database updated')
        render status: :ok
      end
    else
      @service.errors = @db.errors.full_messages
      render status: :unprocessable_entity
    end
  end

  private

    def refresh
      adapter = DbAdapter.new(@db.url)
      service = UpdateDb.new(db: @db)
      return service.run(adapter.dbinfo, adapter.schema)
    end

    def db_params
      params.permit(:url, :max_points_per_plot)
    end
    def set_db
      @db = Db.find(params[:id])
      @nilm = @db.nilm
    end
    #authorization based on nilms
    def authorize_owner
      head :unauthorized  unless current_user.owns_nilm?(@nilm)
    end
    def authorize_viewer
      head :unauthorized  unless current_user.views_nilm?(@nilm)
    end
end
