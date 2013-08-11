class UrlWorker < BaseWorker

  sidekiq_options :queue => :urls,
                  :retry => 1,
                  :backtrace => 1,
                  :unique => true

  def perform(id, force=false)
    url = Url.find(id)
    url.process_url(force)
  end

  def self.process_all
    Url.all.each do |url|
      url.queue_worker(true)
    end
  end

end
