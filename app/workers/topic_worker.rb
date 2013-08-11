class TopicWorker < BaseWorker

  sidekiq_options :queue => :critical,
                  :unique => true,
                  :unique_args => ->(args) { [ args.first, args.last ] }

  def perform(topic_id, since = 1.day.ago, dashboard_id)

    dash = Dashboard.find(dashboard_id)
    topic = Topic.find(topic_id)

    urls = topic.urls_since(since)

    dash.add_urls_async(urls)

  end

end
