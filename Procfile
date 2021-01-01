web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -t 25 -c $SIDEKIQ_CONCURRENCY
release: bundle exec rake db:migrate
