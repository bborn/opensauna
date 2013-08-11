require 'fast_stemmer'

class Topic
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :alternate_names, :type => Array, :default => []
  field :featured, :type => Boolean, :default => false
  field :urls_count, :type => Integer, :default => 0
  field :interests_count, :type => Integer, :default => 0

  has_and_belongs_to_many :urls, :validate => false, :index => true
  has_and_belongs_to_many :interests, :validate => false, :index => true

  validates_uniqueness_of :name, :case_sensitive => false
  validates_length_of :name, minimum: 2

  index({ name: 1 }, { unique: true, name: "name_index"})

  before_save do |t|
    t.urls_count = t.urls.count
    t.interests_count = t.interests.count
  end

  def self.find_or_initialize_with_stemming(name)
    stem = name.stem

    existing_topic = (Topic.with_name(name).all | Topic.with_alternate_name(stem)).uniq.first

    if existing_topic
      existing_topic.stem_name
      return existing_topic
    else
      Topic.new(:name => name, :alternate_names => [stem])
    end
  end

  def stem_name
    stem = name.stem
    unless alternate_names.include?(stem)
      alternate_names << stem
    end
    return self
  end


  def self.with_alternate_name(name)
    Topic.any_in(:alternate_names => [name])
  end

  def self.with_name(name)
    Topic.where(:name => name)
  end

  def cover_image
    img_urls = urls.where(:images.ne => [])
    img_urls.any? ? img_urls.last.images.first : ''
  end

  def self.trigger_interest_workers(topics, url_id)
    topic_ids = topics.map(&:id).uniq.compact
    if topic_ids.any?
      InterestWorker.perform_async(topic_ids, url_id.to_s)
    end
  end

  def urls_since(since = 1.day.ago)

    urls = self.urls.where(:title.ne => '')
    urls = urls.with_images_or_video_or_body
    urls = urls.where(:last_processed_at.ne => nil)
    urls = urls.where(:score.gte => 0)
    urls = urls.where(:created_at.gt => since)

    urls
  end

  def is_popular?(cutoff = 100)
    #is the topic among the 100 with most URLs?
    max = Topic.desc(:urls_count).limit(cutoff).entries.last.urls_count
    count = self.urls_count
    count >= max
  end


end
