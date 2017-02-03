# frozen_string_literal: true

# controller for NILM objects
class NilmsController < ApplicationController
  def index
    nilms = Nilm.all
    render json: nilms
  end

  def show
    nilm = Nilm.find(params[:id])
    render json: nilm
  end
end
