# frozen_string_literal: true

# Controller for DbStreams
class DbStreamsController < ApplicationController
  def update
    stream = DbStream.find(params[:id])
    adapter = DbAdapter.new(stream.db.url)
    service = EditStream.new(adapter)
    service.run(stream, stream_params)
    if service.success?
      render json: {data: stream, messages: service}
    else
      render json: {data: nil, messages: service},
             status: :unprocessable_entity
    end
  end

  private

  def stream_params
    params.require(:stream)
          .permit(:name, :description, :name_abbrev, :hidden,
                  db_elements_attributes:
                  [:id, :name, :units,
                   :default_max, :default_min, :scale_factor, :offset,
                   :plottable, :discrete])
  end
end
