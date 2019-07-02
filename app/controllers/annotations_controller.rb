class AnnotationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stream
  before_action :create_adapter
  before_action :authorize_owner, except: [:index]


  # GET /stream/:stream_id/annotations.json
  def index
    annotations = @node_adapter.get_annotations(@db_stream)
    @service = StubService.new
    render json: annotations, status: @service.success? ? :ok : :unprocessable_entity
  end

  # POST /annotations.json
  def create
    @annotation = Annotation.new
    @annotation.title = params[:title]
    @annotation.content = params[:content]
    @annotation.db_stream = @db_stream
    @annotation.start_time = params[:start]
    @annotation.end_time = params[:end]
    status = @node_adapter.create_annotation(@annotation)
    @service = StubService.new
    render :show, status: @service.success? ? :ok : :unprocessable_entity
  end

  # PATCH/PUT /annotations/1.json
  def update
    @service = EditAnnotation.new(@node_adapter)
    @service.run(params[:id], annotation_params)
    render status: @service.success? ? :ok : :unprocessable_entity
  end

  # DELETE /annotations/1.json
  def destroy
    status = @node_adapter.delete_annotation(params[:id])
    @service = StubService.new
    render 'helpers/empty_response', status: :ok
  end

  private

  def annotation_params
    params.permit(:title, :content, :start, :end, :db_stream_id)
  end

  def set_stream
    @db_stream = DbStream.find(params[:db_stream_id])
    @db = @db_stream.db
    @nilm = @db.nilm
  end

  # authorization based on nilms
  def authorize_owner
    head :unauthorized  unless current_user.owns_nilm?(@nilm)
  end

  def create_adapter
    @node_adapter = NodeAdapterFactory.from_nilm(@nilm)
    if @node_adapter.nil?
      @service = StubService.new
      @service.add_error("Cannot contact installation")
      render 'helpers/empty_response', status: :unprocessable_entity
    end
  end
end
