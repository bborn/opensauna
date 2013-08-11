
task "fix_sources" => :environment do
  tweets = Tweet.where(:source_id.ne => nil)
  tweets.each do |tweet|
    if source = Source.find(:first, :conditions => {:id => tweet.source_id})
      tweet.sources << source
    end
  end
end

task "scrape_images" => :environment do
  require 'image_scraper_worker'
  ImageScraperWorker.scrape_all_since
end

task "fix_scrape_images" => :environment do
  require 'image_scraper_worker'
  ImageScraperWorker.scrape_all_since(3.weeks.ago, true)
end



task :cron_worker => :environment do
  require 'base_worker'
  require 'scheduled_worker'
  require 'source_worker'
  require 'feed_worker'

  puts "Queing source and feed workers ..."
  ScheduledWorker.perform_async
  puts "done."
end


task :flush_redis_and_cache => :environment do
  CarrierWave.clean_cached_files!
  REDIS.flushdb #stupid
end
