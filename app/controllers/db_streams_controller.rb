# frozen_string_literal: true

# Controller for DbStreams
class DbStreamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stream, only: [:update]
  before_action :authorize_owner, only: [:update]

  def update
    adapter = DbAdapter.new(@db.url)
    @service = EditStream.new(adapter)
    @service.run(@db_stream, stream_params)
    render status: @service.success? ? :ok : :unprocessable_entity
  end

  private

  def stream_params
    params.permit(:name, :description, :name_abbrev, :hidden,
                  db_elements_attributes:
                    [:id, :name, :units, :default_max,
                     :default_min, :scale_factor,
                     :offset, :plottable, :discrete])
  end

  def set_stream
    @db_stream = DbStream.includes(:db_elements).find(params[:id])
    @db = @db_stream.db
    @nilm = @db.nilm
  end

  # authorization based on nilms
  def authorize_owner
    head :unauthorized  unless current_user.owns_nilm?(@nilm)
  end

  def authorize_viewer
    head :unauthorized  unless current_user.views_nilm?(@nilm)
  end
end
