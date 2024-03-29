source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.0.1'
# Use PostgreSQL as the database for Active Record
gem "pg", "~> 1.2"
# Use Puma as the app server
gem 'puma', '~> 5.1.1'
# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"
# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
 gem "sprockets-rails"
# import JavaScript modules directly from the browser https://github.com/rails/importmap-rails
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'spring'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "bcrypt", "~> 3.1"

gem "stripe", "~> 5.43"

gem "sidekiq", "~> 6.1"

gem "redis", "~> 4.2", require: %w(redis redis/connection/hiredis)

gem "redis-namespace", "~> 1.8"

gem 'stripe-ruby-mock', require: 'stripe_mock', github: 'stripe-ruby-mock/stripe-ruby-mock', branch: :master

gem "money-rails", "~> 1.13"

gem "devise"

gem "name_of_person", "~> 1.1"

gem "aws-sdk-s3", "~> 1.87"

gem "image_processing", "~> 1.12"

gem "hiredis", "~> 0.6.3"

gem "redis-session-store", github: 'hex-event-solutions/redis-session-store', branch: :master

gem "recaptcha", "~> 5.7"
