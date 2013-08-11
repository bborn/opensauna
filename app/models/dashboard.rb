ActiveSupport::JSON::Encoding.escape_html_entities_in_json = true


class Dashboard
  include ActionView::Helpers
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, :type => String
  field :slug, :type => String
  field :custom_url, :type => String
  field :shared_with_emails, :type => Array, :default => []
  field :is_public, :type => Boolean, :default => false
  field :css, :type => String
  field :custom_html, :type => String, :default => nil
  field :style
  field :is_facebook_stream, :type => Boolean
  field :user_id, :type => Integer
  field :interests, :type => Hash
  field :disinterests, :type => Hash
  field :is_recommended, :type => Boolean
  field :opml_to_import, :type => String

  validates_uniqueness_of :name, :scope => [:user_id]
  validates_presence_of :name

  validates_uniqueness_of :slug, :allow_blank => true
  validates_uniqueness_of :custom_url, :allow_blank => true

  has_and_belongs_to_many :sources, :validate => false, :index => true

  has_and_belongs_to_many :feeds, :validate => false, :index => true

  has_many :posts, :dependent => :destroy, :validate => false

  embeds_many :statistics
  accepts_nested_attributes_for :statistics


  has_many :url_references, :validate => false

  accepts_nested_attributes_for :url_references

  scope :shared_with, lambda {|user|
    if user.admin?
      where(:id => :id)
    else
      # self.or({:shared_with_emails => [user.email]}, {:is_public => true})
      where(:shared_with_emails => [user.email])
    end
  }

  def user
    User.find_by_id(user_id)
  end

  def shared_with?(user)
    shared_with_emails.include?(user.email)
  end

  before_save :set_shared_with
  before_save :set_slug
  after_save :set_custom_domain

  after_create :queue_worker
  after_create :schedule_processed_notification_worker

  attr_accessor :shared_with_emails_string
  attr_accessor :inputs

  def queue_worker
    if is_recommended?
      RecommendedDashboardWorker.perform_async(self.id.to_s, 3.days.ago)
    else
      DashboardWorker.perform_async(self.to_param)
    end
  end



  def set_slug
    if custom_url
      self.slug = custom_url
    end
  end

  def set_custom_domain
    # if Rails.env.staging? || Rails.env.production?
    #   if !new_record? && custom_url_changed? && !custom_url.blank?
    #     heroku_client = Heroku::Client.new(ENV['HEROKU_USERNAME'], ENV['HEROKU_PASSWORD'])
    #     heroku_client.remove_domain(ENV['HEROKU_APP'], custom_url_was) unless custom_url_was.blank?
    #     heroku_client.add_domain(ENV['HEROKU_APP'], custom_url) unless !custom_url.blank?
    #   end
    # end
  end

  def set_shared_with
    shared_with_emails_string.split(',').each do |email|
      if u = User.where(:email => email).first
        shared_with_emails << u.email
      end
    end unless shared_with_emails_string.blank?
    shared_with_emails.uniq!
  end

  def add_inputs(screen_names_or_feed_uris)
    successes, errors = [], []

    if screen_names_or_feed_uris.is_a?(String)
      screen_names_or_feed_uris = screen_names_or_feed_uris.split("\n")
    end

    screen_names_or_feed_uris.each do |string|
      next if string.blank?


      if google_news_search = Feed.google_news_search?(string.strip)
        if s = Feed.add_google_news(google_news_search)
          self.feeds << s
          successes << s
        else
          errors << s
        end
      elsif screenname = Source.screenname?(string.strip)
        if s = Source.find_or_create_by(:name => screenname)
          self.sources << s
          successes << s
        else
          errors << s
        end
      elsif uri = Feed.feed?(string.strip)
        if s = Feed.find_or_create_by(:uri => uri)
          self.feeds << s
          successes << s
        else
          errors << s
        end
      end
    end
    return [successes, errors]
  end

  def add_fb_friends(array)
    array.each do |hash|
      self.sources.create(:name => hash['name'], :fb_uid => hash['id'])
    end
  end

  def urls(page = 1, per = 30)
    references = url_references.only(:url_id).where(:classification.ne => :bad)

    if page
      references = references.limit(100).offset((page.to_i-1)*per.to_i)
    end

    references = references.to_a.map(&:url_id).compact

    us = Url.in(:id => references)
  end

  def urls=(array)
    self.url_references.destroy_all
    add_urls(array)
    self.touch
  end

  def add_urls(array)
    array.each do |u|
      add_url(u)
    end
    self.touch
  end

  def add_urls_async(array)
    array.each do |u|
      add_url_async(u)
    end
  end

  def add_url_async(url)
    DashboardUrlWorker.perform_async(self.id.to_s, url.id.to_s)
  end

  def add_url(url)
    url.reload
    return unless self.should_add_url?(url)

    ref = UrlReference.find_or_initialize_by(:url_id => url.id, :dashboard_id => self.id)
    ref.source_ids = url.cached_sources
    ref.feed_ids   = url.cached_feeds
    ref.with(safe: true).save
    self.touch
  end

  def should_add_url?(url)
    #filter - which URLs should belong?
    (url.score >= 0) &&
      (!url.title.blank?) &&
      (url.image_count > 0 || url.video_count > 0 || !url.body.blank?)
  end

  def refresh_url_references
    Url.any_in(:dashboard_ids => [self.id]).each do |url|
      ref = self.url_references.find_or_create_by(:url_id => url.id)
    end
  end

  def reclassify_url_references
    url_references.each do |ref|
      ref.classify
    end
  end

  def unread_count(time)
    count = urls.with_images_or_video.where(:created_at.gte => (time || 1.year.ago) ).count
    count = "Lots" if (count > 100)
    count
  end

  def process_inputs
    sources.each do |source|
      source.queue_worker
    end
    feeds.each do |feed|
      feed.queue_worker
    end
  end

  def process_urls(only_unprocessed = true, limit = 100)
    to_process = self.urls
    if only_unprocessed
      to_process = to_process.where(:last_processed_at.exists => false).limit(limit)
    end

    to_process.each do |u|
      u.queue_worker
    end
  end

  def cache_key(suffix=nil)
    "dashboard-#{self.id}-#{self.updated_at.to_i}#{suffix}"
  end

  def processing?
    Rails.cache.fetch(cache_key('processing?')) do
      url_references.empty?
    end
  end

  def cover_image
    Rails.cache.fetch(cache_key('cover-image')) do
      img = nil
      url_references.desc(:created_at).each do |ref|
        if img = ref.url.image
          break
        end
      end
      img ? img : "/assets/img-01.jpg"
    end
  end

  def self.public_dashboard_ids(current_user=nil)
    user_id = current_user && current_user.id
    Dashboard.or({:is_public => true}, {:user_id => user_id}).all.map(&:id)
  end

  def bayes_keywords
    c = UrlClassifier.new(self.id)
    words = c.database["dashboard_#{self.id.to_s}_word_frequencies"].find

    results = {'good' => [], 'bad' => []}

    words.each do |h|
      if h['good']
        results['good'] << h['word'].to_s
      end

      if h['bad']
        results['bad'] << h['word'].to_s
      end
    end

    return results
  end


  def min_score_for(type = 'source', scalar = 2)
    stats = Statistic.send("average_#{type}_score_with_deviation", self)
    min = stats[0] - (stats[1] * scalar)
  end

  def source_ids_not_in_score_deviation_with_floor(floor = 0)
    source_min = min_score_for('source')

    if source_min && source_min < floor
      source_ids = self.sources.where(:"scores.#{self.id.to_s}".lte => source_min).map(&:id)
    end

    source_ids.blank? ? nil : source_ids
  end

  def feed_ids_not_in_score_deviation_with_floor(floor = 0)
    feed_min = min_score_for('feed')

    if feed_min && feed_min < floor
      feed_ids = self.feeds.where(:"scores.#{self.id.to_s}".lte => feed_min.to_f).map(&:id).to_a
    end

    feed_ids.blank? ? nil : feed_ids
  end


  def as_json(args)
    return { :id => id,
      :style => style,
      :custom_html => custom_html,
      :css => css,
      :name => name}
  end

  def train(sentiment, url)
    UrlClassifier.train(sentiment, url, self.id)
  end

  def classify(url)
    UrlClassifier.classify(url, self.id)
  end

  def empty?
   !is_recommended? && (sources.count + feeds.count) == 0
  end

  def import_opml_from_url(url)
    file = open(url)
    contents = file.read
    opml = OpmlSaw::Parser.new(contents)
    opml.parse
    feeds = opml.feeds.map{|h| h[:xml_url] }
    self.add_inputs(feeds)
  end

  def schedule_processed_notification_worker
    User.delay_for(10.minutes, :retry => false, :queue => :critical).check_for_processed_dashboards(self.user_id, self.id)
  end


  # Rails Admin
  rails_admin do

    edit do
      include_all_fields
      exclude_fields :url_references, :posts, :statistics
    end

    list do
      field :name
      field :user_id do
        pretty_value do
          if user = bindings[:object].user
            bindings[:view].link_to user.full_name, bindings[:view].rails_admin.show_path('user', user)
          else
            bindings[:view].link_to value, bindings[:view].rails_admin.show_path('user', value)
          end
        end
      end
      field :updated_at
      field :url_references do
        pretty_value do
          value.length.to_s
        end
      end
    end

    show do
      field :name
      field :user_id do
        pretty_value do
          if user = bindings[:object].user
            bindings[:view].link_to user.full_name, bindings[:view].rails_admin.show_path('user', user)
          else
            bindings[:view].link_to value, bindings[:view].rails_admin.show_path('user', value)
          end
        end
      end
      field :is_public
      field :is_recommended
      field :updated_at
      field :url_references do
        pretty_value do
          value.length.to_s
        end
      end


    end


  end


end
