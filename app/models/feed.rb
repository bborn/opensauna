class Feed
  @queue = :feeds
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :title
  field :uri
  field :score, :type => Float, :default => 0.0
  field :scores, :type => Hash, :default => {}
  field :etag
  field :last_fetched_at, :type => DateTime
  field :last_modified, :type => Time

  has_and_belongs_to_many :urls, :validate => false, :index => true

  has_and_belongs_to_many :dashboards, :index => true

  validates_uniqueness_of :uri
  validates_presence_of :uri, :dashboards

  after_create :queue_worker

  index :scores => 1

  def queue_worker
    FeedWorker.perform_async(self.to_param)
  end

  def process_feed
    return if self.last_fetched_at && (Time.now - self.last_fetched_at ) < Source::FETCH_INTERVAL.seconds

    if feed = Feedzirra::Feed.fetch_and_parse(self.uri)
      self.last_fetched_at = DateTime.now

      self.title = feed.title
      self.name  = self.title

      self.etag             = feed.etag
      self.last_modified    = feed.last_modified
      feed.sanitize_entries!

      feed.entries.each do |entry|
        u = Url.find_or_initialize_by_url(entry.url)
        u.feeds << self                   unless self.urls.include?(u)
        u.title = entry.title             unless entry.title.blank?
        u.description = entry.summary     unless entry.summary.blank?
        u.lede = entry.summary            unless entry.summary.blank?
        u.body = entry.content            unless entry.content.blank?
        u.published_at = entry.published  unless entry.published.blank?
        u.with(safe: true).save
      end

      self.save

    end
  end


  def score_for(dashboard_id)
    self.scores[dashboard_id.to_s] || 0
  end

  def score_class(dashboard)
    if score = self.score_for(dashboard.id)
      avg, dev = Statistic.average_feed_score_with_deviation(dashboard)
      # puts "bad #{avg - dev} neutral #{avg + dev} good"

      if score < (avg - dev)
        'bad'
      elsif score > (avg + dev)
        'good'
      else
        'neutral'
      end
    end
  end

  def change_score(str, dashboard_id)
    # self.update_attribute('score', ((self.score||0) + str.to_f))
    self.scores[dashboard_id.to_s] = self.score_for(dashboard_id.to_s) + str.to_f
    self.save
  end

  def name_or_title
    name || title
  end

  def self.feed?(string)
    uris = PostRank::URI.extract(string)
    return false if uris.empty?
    return false if uris.first.include?('twitter.com')
    uri = uris.first

    begin
      agent = Mechanize.new
      uri = agent.get(uri).uri

      feed = Feedbag.find(uri.to_s).first
    rescue
      Rails.logger.debug("Failed fetching feed: #{$!}")
    end

    return feed
  end

  def self.google_news_search?(string)
    match = string.match(/^s\:(.*$)/)
    match ? match[1].strip : false
  end

  def self.add_google_news(string)
    uri = PostRank::URI.extract("https://news.google.com/news/feeds?q=#{CGI.escape string}&output=rss").first
    feed = Feed.find_or_create_by(:uri => uri)
    feed
  end

end
