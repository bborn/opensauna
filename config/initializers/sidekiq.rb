
Sidekiq.configure_server do |config|
  config.failures_default_mode = :exhausted
end


SidekiqUniqueJobs::Config.unique_args_enabled = true
