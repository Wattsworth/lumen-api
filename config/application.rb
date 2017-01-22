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
    # Add folders under the services directory
    %w(nilm db db_folder db_stream).each do |service|
      config.autoload_paths << Rails.root.join("app/services/#{service}")
    end
  end
end
