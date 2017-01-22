# frozen_string_literal: true

# Controller for DbStreams
class DbStreamsController < ApplicationController
  def update
    stream = DbStream.find(params[:id])
    adapter = DbAdapter.new(stream.db.url)
    service = EditStream.new(adapter)
    service.run(stream, stream_params.symbolize_keys)
    if(service.success?)
      render json: stream
    else
      render json: service, status: :unprocessable_entity
    end
  end

  private
    def stream_params
      params.permit(:name, :description, :hidden, :name_abbrev, :elements)
    end

end
