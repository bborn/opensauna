class UrlClassifier < BaseClassifier
  sidekiq_options :queue => :critical, :backtrace => 4

  CLASSES = [:good, :bad]

  def initialize(dashboard_id)
    super("dashboard_#{dashboard_id}")
  end

  def perform(id, dashboard_id, action = 'classify')
    url = Url.find(id)

    if action.eql?('classify')
      UrlClassifier.classify(url, dashboard_id)
    elsif action.eql?('train')
      UrlClassifier.train(url.score_class, url, dashboard_id)
    end
  end

  def self.classify(url, dashboard_id)
    c = new(dashboard_id)
    c.classifier.classify(url.to_bayes, CLASSES)
  end

  def self.classifications(url, dashboard_id)
    c = new(dashboard_id)
    c.classifier.classifications(url.to_bayes, CLASSES)
  end

  def self.train(sentiment, url, dashboard_id)
    c = new(dashboard_id)
    c.classifier.train(sentiment.to_sym, url.to_bayes)
  end

end
