Rails.application.config.action_mailer.smtp_settings = {
  address:              'email-smtp.us-east-1.amazonaws.com',
  port:                 587,
  user_name:            Rails.application.credentials.aws[:ses][:username],
  password:             Rails.application.credentials.aws[:ses][:password],
  authentication:       :login,
  enable_starttls_auto: true
}
Rails.application.config.action_mailer.raise_delivery_errors = true
Rails.application.config.action_mailer.perform_deliveries = true
