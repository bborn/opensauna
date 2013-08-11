

class AppWorker < BaseWorker

  def perform
    FeedWorker.process_all
    SourceWorker.process_all
    UrlWorker.process_all
    TweetWorker.process_all
  end


  def self.process_all
    AppWorker.perform_async
  end

end
