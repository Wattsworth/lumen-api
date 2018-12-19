class HomeController < ApplicationController

  # GET /
  def index
    @version = Rails.configuration.app_version
    @node_name = Rails.configuration.node_name
    @send_emails = Rails.configuration.send_emails
  end

end
