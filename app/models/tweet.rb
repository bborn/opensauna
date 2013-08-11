class Tweet

  include Mongoid::Document
  include Mongoid::Timestamps

  has_and_belongs_to_many :sources, :validate => false, :autosave => true
  has_and_belongs_to_many :urls, :validate => false, :autosave => true, index: true

  field :id_str, :type => Integer
  field :text
  field :cached_urls, :type => Array
  field :tweeted_at, :type => DateTime
  field :score, :type => Float, :default => 0.to_f

  validates_uniqueness_of :id_str
  validates_presence_of :id_str, :text

  after_create :queue_worker

  def source
    sources.first
  end

  def queue_worker
    TweetWorker.perform_async(self.to_param)
  end

  def record_urls
    cached_urls.each do |e|
      url = Url.find_or_initialize_by_url(e)
      self.urls << url unless self.urls.include?(url)
    end if cached_urls
    self.with(safe: true).save!
  end

  def change_score(str, dashboard_id)
    self.score += str.to_f
    self.sources.each{|s| s.change_score(str, dashboard_id) }
    self.save
  end

end
