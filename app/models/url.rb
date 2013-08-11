class Url

  include Mongoid::Document
  include Mongoid::Timestamps
  include UrlProcessor

  has_and_belongs_to_many :tweets, :autosave => true, :index => true
  has_and_belongs_to_many :feeds, :autosave => true
  has_and_belongs_to_many :fb_sources, :class_name => "Source"
  has_and_belongs_to_many :topics, :validate => false, :index => true

  has_many :images, :validate => false, :as => :attachable


  belongs_to :domain, :index => true

  field :u, :as => :url
  field :s_u, :as => :short_url, :default => nil
  field :ts, :as => :titles, :type => Array, :default => []
  field :t, :as => :title, :default => nil
  field :is, :as => :cached_images, :type => Array, :default => []
  field :ic, :as => :image_count, :type => Integer, :default => 0
  field :v, :as => :video, :default => nil
  field :v_e, :as => :video_embeds, :type => Array, :default => []
  field :vc, :as => :video_count, :type => Integer, :default => 0
  field :l, :as => :lede
  field :d, :as => :description
  field :ds, :as => :descriptions, :type => Array, :default => []
  field :b, :as => :body
  field :h_b, :as => :html_body
  field :k, :as => :keywords
  field :k_l, :as => :keyword_list, :type => Array, :default => []
  field :f, :as => :favicon
  field :p_a, :as => :published_at, :type => DateTime
  field :lp, :as => :last_processed_at, :type => DateTime
  field :ss, :as => :score, :type => Float, :default => 0.to_f
  field :c, :as => :classification, :type => Hash, :default => {}
  field :t_c, :as => :tweets_count, :type => Integer, :default => 0
  field :c_s, :as => :cached_sources, :type => Array, :default => []
  field :c_f, :as => :cached_feeds, :type => Array, :default => []
  field :d_ids, :as => :dashboard_ids, :type => Array, :default => []
  field :f_s, :as => :facebook_shares, :type => Integer, :default => 0
  field :s_c, :as => :sentence_count, :type => Integer, :default => 0

  index({ url: 1 }, { unique: true, name: "url_index", drop_dups: true})

  index :tweets_count => 1
  index :created_at => 1
  index :score => 1
  index :facebook_shares => 1

  validates_uniqueness_of :url, :case_sensitive => false

  before_create :normalize_url!


  after_create :queue_worker


  after_save do |record|
    if images.any? && (post = Post.where(:url_id => record.id).first)
      post.update_images_from_url
    end
  end

  after_destroy :destroy_references

  before_save :compact_images
  before_save :count_images
  before_save :count_videos
  after_save :cache_feeds_and_sources_and_dashboards

  scope :with_images_or_video, any_of({:image_count.ne => 0}, {:video_count.ne => 0})
  scope :with_body, where({:body.exists => true})
  scope :with_title, where(:title.ne => '').and(:title.exists => true)
  scope :with_images_or_video_or_body, any_of(Url.with_images_or_video.selector, Url.with_body.selector)

  def self.without_source_ids(ids)
    if ids.blank?
      self.scoped
    else
      self.where({:cached_sources.nin => ids})
    end
  end

  def self.without_feed_ids(ids)
    if ids.blank?
      self.scoped
    else
      self.where({:cached_feeds.nin => ids})
    end
  end

  def self.without_source_or_feed_ids(source_ids, feed_ids)
    selectors = [Url.without_source_ids(source_ids).selector , Url.without_feed_ids(feed_ids).selector]
    selectors = selectors.reject{|s| s.eql?({})}

    selectors.size.eql?(0) ? Url.where(:id.exists => true) : Url.all_of(selectors)
  end

  def self.destroy_urls_before(time = 1.month.ago, score = 0)
    self.where(:created_at.lte => time, :score.lte => score).destroy_all
  end

  def image_urls(size=nil)
    images.any? ? images.map{|i| i.file.url(size) } : cached_images
  end

  def image(size=nil)
    image_urls.any? && image_urls(size).first
  end

  # alias_method :original_images=, :images=
  # def images=(array)
  #   if array.any?
  #     if array.first.is_a?(String)
  #       self.cached_images = array
  #     elsif array.first.is_a?(Image)
  #       puts array.inspect
  #       self.original_images = array
  #     end
  #   end
  # end

  def compact_images
    unless self.cached_images.blank?
      self.cached_images = self.cached_images.to_a.reject(&:blank?).compact.uniq
    else
      self.cached_images = []
    end
  end

  def count_images
    self.image_count = (self.images.any? && self.images.count) || cached_images.size
  end

  def count_videos
    self.image_count = self.images.count
  end

  def destroy_references
    self.dashboard_ids.each do |dash_id|
      Dashboard.find(dash_id).url_references.find_by(:url_id => self.id)
    end
  end

  def cache_feeds_and_sources_and_dashboards

    sources_array = tweets.map{|t|
      t.sources.map(&:id)
    }.flatten

    fb_sources.each do |fb_source|
      sources_array << fb_source.id
    end

    feeds_array = feeds.map{|f|
      f.id
    }

    dashboards_array = []

    tweets.each{|t|
      dashboards_array << t.sources.map{|s| s.dashboard_ids}.flatten.uniq
    }

    fb_sources.each do |fb_source|
      dashboards_array << fb_source.dashboard_ids
    end

    feeds.each {|f|
      dashboards_array << f.dashboard_ids
    }
    dashboards_array << dashboard_ids.map{|e| e.is_a?(String) ? Moped::BSON::ObjectId.from_string(e) : e}
    dashboards_array = dashboards_array.flatten.uniq

    self.set('c_f', feeds_array)
    self.set('c_s', sources_array)
    self.set('d_ids', dashboards_array)
  end

  def add_to_dashboards
    dashboard_ids.each do |d_id|
      DashboardUrlWorker.perform_async(d_id.to_s, self.id.to_s)
    end
  end

  def queue_worker(force=false)
    UrlWorker.perform_async(self.to_param, force)
  end

  def self.find_or_initialize_by_url(str)
    str = Url.normalize_url(str)
    u = Url.find_or_initialize_by(:url => str)
    u
  end

  def self.fetch(uri_str)

    agent = Mechanize.new {|a|
      a.read_timeout   = 5
      a.open_timeout   = 5
      a.redirection_limit = 3
    }

    u = agent.get(uri_str).uri.to_s

    return u
  end

  def self.normalize_url(str)
    str = self.fetch(str)
    uri = PostRank::URI.clean(str)
    uri.to_s
  end

  def normalize_url!
    new_url = Url.normalize_url(self.url)
    if self.url != new_url
      self.short_url = self.url
      self.url = new_url
    end
  end

  def change_score(str, dashboard_id)
    self.score += str.to_f

    self.tweets.each do |t|
      t.change_score(str, dashboard_id)
    end

    self.fb_sources.each do |fb_source|
      fb_source.change_score(str, dashboard_id)
    end

    self.feeds.each do |f|
      f.change_score(str, dashboard_id)
    end

    self.save
  end

  def domain_name
    domain && domain.name
  end

  def to_bayes
    hash = {
      :title => (self.title || nil),
      :keywords => (!self.keyword_list.blank? && self.keyword_list.any? && self.keyword_list.join(" "))
    }
    hash = hash.delete_if{|k,v| v.blank? }
    return hash.values.join(' ')
  end


  def score_class
    if score < 0
      'bad'
    elsif score > 0
      'good'
    else
      'neutral'
    end
  end

  def tall_class?
    return true if score > 0
    return true if !image_count.zero? && !body.blank?
  end

  def datetime
    published_at
  end

  def source
    cached_sources.first
  end

  def feed
    cached_feeds.first
  end

  def source_name
    (source && source['name']) || (feed && feed['name_or_title'])
  end

  def generated_classification
    (classification.blank? || classification.eql?('neutral')) ? source_classification  : classification
  end

  def source_classification
    (source && source['score_class']) || (feed && feed['score_class'])
  end

  def short_text_for_item
    unless @short_text_for_item
      str = ''

      str = [body, description, lede].reject{|s| s.blank? }.compact.first

      @short_text_for_item = str
    end
    @short_text_for_item
  end

  def long_text_for_item
    unless @long_text_for_item
      texts = [html_body, body, description, lede]
      str = ''

      texts.each do |text|
        sanitized = Sanitize.clean(text, :elements => %w(a span p br blockquote), :attributes => {'a' => ['href']}, :remove_contents => false )
        next if sanitized.blank?
        str = sanitized
        break
      end

      @long_text_for_item = str
    end

    @long_text_for_item
  end

  def text_for_item(length = 150)
    str = (lede || description || '')
    return Sanitize.clean(str).truncate(length, :separator => ' ', :omission => '...')
  end

  def formatted_updated_at
    updated_at && updated_at.to_s(:short)
  end

  def video_embed
    video_embeds && video_embeds.first.to_s.html_safe
  end

  def tweet_url
    short_url || url
  end

  def self.json_opts
    { :only => [:title, :favicon, :images, :_id, :score, :url],
      :methods => [:text_for_item, :long_text_for_item, :formatted_updated_at, :source_name, :generated_classification, :video_embed, :tweet_url]}
  end


  def image_urls_from_html
    begin
      uri = URI.parse(self.url)
      doc = Hpricot( open( uri ) )
    rescue
      return []
    end

    page_title = (doc/"title")
    # get the images
    images = []
    (doc/"img").each do |img|
      begin
        if URI.parse(URI.escape(img['src'])).scheme.nil?
          img_uri = "#{uri.scheme}://#{uri.host}/#{img['src']}"
        else
          img_uri = img['src']
        end

        images << img_uri
      rescue
        nil
      end
    end

    return images
  end




  rails_admin do

    list do
      field :url
      field :title
      field :domain do
        pretty_value do
          value && value.name
        end
      end
      field :topics do
        pretty_value do
          value && value.map(&:name).to_sentence
        end
      end

    end

  end


end
