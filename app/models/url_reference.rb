

class UrlReference

  include Mongoid::Document
  include Mongoid::Timestamps

  # embedded_in :dashboard
  belongs_to :dashboard, :index => true
  field :url_id
  field :dashboard_id
  field :classification
  field :score, :type => Integer, :default => 0
  field :source_ids, :type => Array, :default => []
  field :feed_ids, :type => Array, :default => []
  belongs_to :url, :index => true

  validates_uniqueness_of :url_id, :scope => [:dashboard_id]
  validates_presence_of :url_id

  after_create :queue_classifier


  def self.without_source_ids(ids)
    if ids.blank?
      self.scoped
    else
      self.where({:source_ids.nin => ids})
    end
  end

  def self.without_feed_ids(ids)
    if ids.blank?
      self.scoped
    else
      self.where({:feed_ids.nin => ids})
    end
  end

  def self.without_source_or_feed_ids(source_ids, feed_ids)
    selectors = [UrlReference.without_source_ids(source_ids).selector , UrlReference.without_feed_ids(feed_ids).selector]
    selectors = selectors.reject{|s| s.eql?({})}

    selectors.size.eql?(0) ? UrlReference.where(:id.exists => true) : UrlReference.all_of(selectors)
  end

  def queue_classifier
    UrlReferenceWorker.perform_async(self.id.to_s)
  end

  def classify
    if res = UrlClassifier.classifications(url, dashboard.id)
      return if res.size < 2 #if only one class was found
      prob = res.sort_by { |c| -c[1] }.first
      if prob.last < 0.8
        self.update_attribute(:classification, nil)
      else
        self.update_attribute(:classification, prob.first)
      end
    end
  end


end
