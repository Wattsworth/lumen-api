# frozen_string_literal: true

# Controller for DbFolders
class DbFoldersController < ApplicationController
  def show
    folder = DbFolder.find(params[:id])
    render json: folder, shallow: false
  end

#TODO: add db attribute to folders and streams
#TODO: add timespan and disk usage stats to folders
#TODO: create info stream on folders on edit
  def update
    folder = DbFolder.find(params[:id])
    adapter = DbAdapter.new(folder.db.url)
    service = EditFolder.new(adapter)
    render json: service.run(folder, params)
  end

  private
    def folder_params
      params.permit(:name, :description,:hidden)
    end


end
