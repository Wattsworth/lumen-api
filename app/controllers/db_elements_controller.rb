# frozen_string_literal: true
class DbElementsController < ApplicationController
  before_action :authenticate_user!


  #def index
  #  @elements = DbElement.find(JSON.parse(params[:elements]))
  #  # make sure the user is allowed to view these elements
  #  @elements.each do |elem|
  #    unless current_user.views_nilm?(elem.db_stream.db.nilm)
  #      head :unauthorized
  #      return
  #    end
  #  end
  #end

  def data
    req_elements = DbElement.find(JSON.parse(params[:elements]))
    # make sure the user is allowed to view these elements
    req_elements.each do |elem|
      unless current_user.views_nilm?(elem.db_stream.db.nilm)
        head :unauthorized
        return
      end
    end
    # make sure the time range makes sense
    start_time = (params[:start_time].to_i unless params[:start_time].nil?)
    end_time = (params[:end_time].to_i unless params[:end_time].nil?)

    # retrieve the data for the requested elements
    @service = LoadElementData.new
    @service.run(req_elements, start_time, end_time)
    @start_time = @service.start_time
    @end_time = @service.end_time

    # update the user's home view if a data view instance is provided
    if params[:redux_json]!=nil
      service = CreateDataView.new()
      service.run({redux_json: params[:redux_json]},
        nil, current_user, home_view=true)
      unless service.success?
        Rails.logger.warn("error creating home view for #{current_user.id}")
      end
    end
    render status: @service.success? ? :ok : :unprocessable_entity
  end
end
