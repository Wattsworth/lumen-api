class DataViewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_data_view, only: [:update, :destroy]
  before_action :authorize_owner, only: [:update, :destroy]

  def index
    @data_views = DataView.find_viewable(current_user)
  end

  # POST /data_views.json
  def create
    @service = CreateDataView.new()
    @service.run(data_view_params, params[:stream_ids], current_user)
    @data_view = @service.data_view
    render :show, status: @service.success? ? :ok : :unprocessable_entity
  end

  # PATCH/PUT /data_views/1.json
  def update
    @service = StubService.new
    if @data_view.update(updatable_data_view_params)
      @service.add_notice('updated data view')
      render :show, status: :ok
    else
      @service.errors = @data_view.errors.full_messages
      render :show, status: :unprocessable_entity
    end
  end

  # DELETE /data_views/1.json
  def destroy
    @service = StubService.new
    @data_view.destroy
    @service.set_notice('removed data view')
    render 'helpers/empty_response', status: :ok
  end

  private

  def data_view_params
    params.permit(:name, :description, :image, :redux_json)
  end

  def updatable_data_view_params
    params.permit(:name, :description)
  end

  def set_data_view
    @data_view = DataView.find(params[:id])
  end

  def authorize_owner
    head :unauthorized  unless @data_view.owner == current_user
  end

end
