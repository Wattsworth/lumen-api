# frozen_string_literal: true

# Controller for DbFolders
class DbFoldersController < ApplicationController
  def show
    folder = DbFolder.find(params[:id])
    render json: folder, shallow: false
  end

end
