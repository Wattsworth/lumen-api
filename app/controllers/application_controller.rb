# frozen_string_literal: true

# application controller
class ApplicationController < ActionController::API
  before_action :configure_permitted_parameters, if: :devise_controller?
  include DeviseTokenAuth::Concerns::SetUserByToken

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update,
      keys: [:first_name, :last_name, :email])
  end
end
