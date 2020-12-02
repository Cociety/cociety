require 'stripe'
Stripe.api_key = Rails.application.credentials.stripe[ENV['RAILS_ENV'].to_sym][:secret]
