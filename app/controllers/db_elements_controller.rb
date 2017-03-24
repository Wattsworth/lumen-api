class DbElementsController < ApplicationController
  before_action :authenticate_user!

  def index
    req_elements = DbElement.find(params[:elements])
    #make sure the user is allowed to view these elements
    req_elements.each do |elem|
      unless current_user.views_nilm?(elem.db_stream.db.nilm)
        head :unauthorized
        return
      end
    end
    #make sure the time range makes sense
    @start_time = params[:start_time].to_i
    @end_time = params[:end_time].to_i
    unless @end_time>@start_time
      head :unprocessable_entity
      return
    end
    #retrieve the data for the requested elements
    @service = LoadElementData.new
    @service.run(req_elements, @start_time, @end_time)
    render status: @service.success? ? :ok : :unprocessable_entity
  end

end
