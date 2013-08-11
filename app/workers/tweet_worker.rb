
class TweetWorker < BaseWorker
  sidekiq_options :retry => false,
                  :unique => true

  def perform(id)
    Tweet.find(id).record_urls
  end



  def self.process_all
    Tweet.all.each do |tweet|
      tweet.queue_worker
    end
  end


end
