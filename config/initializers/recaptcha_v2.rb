Recaptcha.configure do |config|
  config.site_key  = Rails.application.credentials.dig(:recaptcha, :v2, :site_key)
  config.secret_key = Rails.application.credentials.dig(:recaptcha, :v2, :secret_key)
end