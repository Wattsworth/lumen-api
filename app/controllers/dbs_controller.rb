# frozen_string_literal: true

# Controller for Database Objects
class DbsController < ApplicationController
  def show
    db = Db.find(params[:id])
    render json: db
  end

  def update
    db = Db.find(params[:id])
    prev_url = db.url
    if db.update_attributes(db_params)
      if(prev_url != db.url || params[:refresh])
        refresh(db) and return
      end
      stub = StubService.new()
      stub.add_notice("database updated")
      render json: {data: db,
                    messages: stub}
    else
      render json: "adfs"
    end
  end

  private

    def refresh(db)
      adapter = DbAdapter.new(db.url)
      service = UpdateDb.new(db: db)
      service.run(adapter.dbinfo, adapter.schema)
      if(service.success?)
        render json: {data: db, messages: service}
      else
        render json: {data: nil, messages: service},
          status: :unprocessable_entity
      end
    end


    def db_params
      params.permit(:url, :max_points_per_plot)
    end

end
