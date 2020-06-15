# frozen_string_literal: true

Rails.application.configure do
  $n_exams_question = 3
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
        'Cache-Control' => "public, max-age=#{2.days.seconds.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.console = Pry

  Octokit.configure do |c|
    c.client_id        = ENV['GITHUB_APP_KEY']
    c.client_secret    = ENV['GITHUB_APP_KEY_SECRET']
  end

  # SMTP GMail Settings
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: 'localhost:3000' }

  # Use letter opener to open emails i development mode
  # config.action_mailer.delivery_method = :smtp
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.perform_deliveries = true

  # GMAIL SETUP
  config.action_mailer.smtp_settings = {
    address: 'smtp.sendgrid.net',
    port: 587,
    user_name: ENV['SMTP_USER'],
    password: ENV['SMTP_PASSWORD'],
    authentication: 'plain',
    enable_starttls_auto: true
  }

  # config.force_ssl = true

  config.paperclip_defaults = {
    storage: :s3,
    s3_region: ENV.fetch('AWS_REGION', 'us-west-2'),
    s3_credentials: {
      bucket: ENV.fetch('S3_BUCKET_NAME', 'makerspace-testing-for-real'),
      access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID', 'wrong'),
      secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', 'wrong')
    }
  }
end
