require 'stripe'
env = ENV["RAILS_ENV"] || "development"
Stripe.api_key = Rails.application.credentials.stripe[env.to_sym][:secret]
