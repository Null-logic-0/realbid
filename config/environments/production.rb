require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Reloading
  config.enable_reloading = false
  config.eager_load = true

  # Error reports
  config.consider_all_requests_local = false

  # Secret key
  config.secret_key_base = Rails.application.credentials.dig(:production, :secret_key_base)

  # Caching
  config.action_controller.perform_caching = true
  config.cache_store = :memory_store # simple default

  # Static files
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
  config.public_file_server.headers = { "Cache-Control" => "public, max-age=#{1.year.to_i}" }

  # SSL
  config.force_ssl = true
  config.assume_ssl = true

  # Logging
  config.log_tags = [ :request_id ]
  config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Active Storage
  config.active_storage.service = :amazon

  # Active Job
  config.active_job.queue_adapter = :async

  # Mailer
  config.action_mailer.default_url_options = { host: "yourdomain.com" }

  # i18n
  config.i18n.fallbacks = true

  # Schema
  config.active_record.dump_schema_after_migration = false
end
