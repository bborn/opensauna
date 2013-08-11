class UserClassifier < BaseClassifier

  def initialize(user_id)
    super("user_#{user_id}")
  end

  def self.classify(user, url)
    c = new(user.id)
    c.classifier.classify(url.to_bayes)
  end

  def self.train(sentiment, url, user)
    c = new(user.id)
    c.classifier.train(sentiment.to_sym, url.to_bayes)
  end

end
