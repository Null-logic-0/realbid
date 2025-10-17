require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Realbid
  class Application < Rails::Application
    config.load_defaults 8.0

    config.autoload_lib(ignore: %w[assets tasks])

    config.active_job.queue_adapter = :sidekiq

    config.exceptions_app = self.routes
  end
end
