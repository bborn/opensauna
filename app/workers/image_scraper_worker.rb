class ImageScraperWorker < BaseWorker
  sidekiq_options :retry => false,
                  :unique => true

  def perform(id, force=nil)

    count = 0

    url = Url.find(id)
    url.scrape_images(force)
    count = url.images.size

  end



  def self.scrape_all_since(time = 1.week.ago, force=nil)
    Url.where(:created_at.gt => time, :score.gt => 0).each do |url|
      ImageScraperWorker.perform_async(url.to_param, force)
    end
  end

end
