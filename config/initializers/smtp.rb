Rails.application.configure do
  smtp_provider = Rails.env == "dev_server" ? :mailtrap : :amazon_ses # :sendinblue or :sendgrid (Send in blue limit is really low)
  smtp_credentials =
    Rails.application.credentials[Rails.env.to_sym][:smtp][smtp_provider]

  break if smtp_credentials.nil?

  config.action_mailer.smtp_settings = {
    address: smtp_credentials[:address],
    port: smtp_credentials[:port],
    user_name: smtp_credentials[:user_name],
    password: smtp_credentials[:password],
    authentication: :plain,
    enable_starttls_auto: true
  }

  config.action_mailer.default_url_options = { host: "makerepo.com" }
end
