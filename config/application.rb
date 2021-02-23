require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Cociety
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.autoload_paths << Rails.root.join('lib')

    config.action_view.field_error_proc = proc { |html_tag, instance|
      error_tags = html_tag.starts_with?('<input ') ? instance.full_error_messages.map { |m| "<div class=\"field_error\">#{m}</div>" }.join : ''
      "<div class=\"field_with_errors\">#{html_tag}#{error_tags}</div>".html_safe
    }
  end
end
