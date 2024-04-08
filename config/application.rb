require_relative "boot"

require "rails/all"
require 'http'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TodoBackend
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'http://localhost:3001'  # Add any other origins as needed
        resource '/api/*', headers: :any, methods: [:get, :post, :put, :patch, :delete, :options, :head]
      end
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
