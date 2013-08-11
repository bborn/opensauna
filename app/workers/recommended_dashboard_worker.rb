class RecommendedDashboardWorker < BaseWorker

  sidekiq_options :queue => :critical,
                  :unique => true,
                  :unique_job_expiration => 60,
                  :unique_args => ->(args) { [ args.first ] }

  def perform(dashboard_id, since = 1.day.ago)


    if dash = Dashboard.find(dashboard_id)
      user = User.find(dash.user_id)

      user.interest.topic_ids.each do |topic_id|
        TopicWorker.perform_async(topic_id.to_s, since, dashboard_id.to_s)
      end

    end

  end

  def self.perform_now(dashboard_id, since = 1.day.ago)
    RecommendedDashboardWorker.new.perform(dashboard_id, since)
  end

end
