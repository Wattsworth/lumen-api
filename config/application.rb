require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ControlPanel
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.api_only = true
    # Add folders under the services and adapters directory
    %w(data nilm db db_folder db_stream permission user_group user data_view).each do |service|
      config.autoload_paths << Rails.root.join("app/services/#{service}")
    end
    config.autoload_paths << Rails.root.join("app/adapters")
  end
end
