# frozen_string_literal: true

# Controller for Database Objects
class DbsController < ApplicationController
  def show
    db = Db.find(params[:id])
    render json: db
  end
end
