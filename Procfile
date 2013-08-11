web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
sidekiq_default: bundle exec sidekiq -q default -c 10
sidekiq_critical: bundle exec sidekiq -q critical -c 10
sidekiq_urls: bundle exec sidekiq -q urls -c 10
sidekiq_dashboard_urls: bundle exec sidekiq -q dashboard_urls -c 10
