class Source
  include Mongoid::Document
  include Mongoid::Timestamps
  FETCH_INTERVAL = 3600

  field :name
  field :fb_uid
  field :last_fetched_at, :type => DateTime
  field :score, :type => Float, :default => 0.0
  field :scores, :type => Hash, :default => {}

  validates_presence_of :name, :dashboards
  validates_uniqueness_of :name

  has_and_belongs_to_many :tweets, :dependent => :delete, :validate => false
  has_and_belongs_to_many :urls, :validate => false, :index => true

  # belongs_to :dashboard
  has_and_belongs_to_many :dashboards, :index => true

  after_create :queue_worker

  index :scores => 1

  def queue_worker
    SourceWorker.perform_async(self.to_param)
  end

  def process
    if fb_uid
      process_fb_posts
    else
      process_tweets
    end
  end

  def process_fb_posts
    if !self.last_fetched_at || (Time.now - self.last_fetched_at ) > Source::FETCH_INTERVAL.seconds
      begin
        record_posts(fetch_posts)
        self.last_fetched_at = DateTime.now
        self.save
        return true
      rescue

        Rails.logger.debug "ERROR processing FB posts: #{$!}"
      end
    end
  end

  def process_tweets
    if !self.last_fetched_at || (Time.now - self.last_fetched_at ) > Source::FETCH_INTERVAL.seconds
      begin
        record_tweets(fetch_tweets)
        self.last_fetched_at = DateTime.now
        self.save
        return true
      rescue
        Rails.logger.debug "ERROR processing Tweets: #{$!}"
      end
    end
  end

  def fetch_tweets
    result = Twitter.user_timeline(self.name, {:include_entities => true})
    result
  end

  def fetch_posts
    if provider = Authentication.find_by_uid(self.fb_uid)
      result = MiniFB.get(provider.token, self.fb_uid, :type => 'posts')['data']
      result
    end
  end

  def record_posts(new_posts)
    new_posts.each do |p|
      text = "#{p['message']} #{p['link']} #{p['caption']}"
      #concat all the text that might contain a link

      uris = PostRank::URI.extract(text)
      #extract URIs

      if uris.any?
        uri = uris.first
        #we just want the first link, not all of them

        u = Url.find_or_initialize_by_url(uri)
        u.fb_sources << self unless self.urls.include?(u)
        u.with(safe: true).save

      end
    end
  end


  def record_tweets(new_tweets)
    new_tweets.each do |t|
      if tweet = Tweet.where(:id_str => t.id.to_i).first
        tweet.sources << self
        tweet.save
        #do nothing
      elsif !t.urls.blank?
        tweet = self.tweets.create!(:id_str => t.id.to_i, :text => t.text, :tweeted_at => t.created_at, :cached_urls => t.urls.map(&:url))
      end
    end
  end

  def change_score(str, dashboard_id)
    # self.update_attribute('score', ((self.score||0) + str.to_f))
    self.scores[dashboard_id.to_s] = self.score_for(dashboard_id.to_s) + str.to_f
    self.save
  end

  def score_for(dashboard_id)
    self.scores[dashboard_id.to_s] || 0
  end

  def score_class(dashboard)
    if score = self.score_for(dashboard.id)
      avg, dev = Statistic.average_source_score_with_deviation(dashboard)

      if score < (avg - dev)
        'bad'
      elsif score > (avg + dev)
        'good'
      else
        'neutral'
      end
    end
  end

  def self.screenname?(string)
    begin
      Twitter.user(string)
    rescue Twitter::Error::NotFound, Twitter::Error::ClientError
      return false
    end

    return string
  end

end
