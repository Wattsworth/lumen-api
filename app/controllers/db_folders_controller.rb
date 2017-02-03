# frozen_string_literal: true

# Controller for DbFolders
class DbFoldersController < ApplicationController
  def show
    folder = DbFolder.find(params[:id])
    render json: folder, shallow: false
  end

#TODO: create info stream on folders on edit
  def update
    folder = DbFolder.find(params[:id])
    adapter = DbAdapter.new(folder.db.url)
    service = EditFolder.new(adapter)
    service.run(folder, folder_params)
    if service.success?
      render json: {data: folder, messages: service}, shallow: false
    else
      render json: {data: nil, messages: service},
             status: :unprocessable_entity
    end
  end

  private
    def folder_params
      params.permit(:name, :description,:hidden)
    end


end
