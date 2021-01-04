ENV['SIDEKIQ_REDIS_URL'] ||= ENV['REDIS_URL']

Rails.application.config.active_job.queue_adapter = :sidekiq

Sidekiq.configure_server do |config|
  config.redis = { url: ENV['SIDEKIQ_REDIS_URL'], namespace: "cociety_jobs_#{Rails.env}" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['SIDEKIQ_REDIS_URL'], namespace: "cociety_jobs_#{Rails.env}" }
end
