class FeedWorker < BaseWorker
  sidekiq_options :retry => false,
                  :unique => true,
                  :backtrace => 10

  def perform(id)

    feed = Feed.find(id)
    feed.process_feed


  end



  def self.process_all
    Feed.all.each do |feed|
      feed.queue_worker
    end
  end


end
