ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'sidekiq/testing'
require 'support/sidekiq_helper'
require 'support/stripe_support'

class ActiveSupport::TestCase
  include StripeSupport
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  Sidekiq.logger.level = Logger::FATAL
  Sidekiq::Testing.fake!

  # Add more helper methods to be used by all tests here...

  def file_fixture_json(file_path)
    file = file_fixture(file_path).read
    JSON.parse(file)
  end
end
