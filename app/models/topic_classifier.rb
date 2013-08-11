class TopicClassifier < BaseClassifier

  def initialize
    super("TopicClassifier")
  end

  def self.classify(string)
    return if string.blank?
    c = new
    c.classifier.classify(string)
  end

  def self.train(topic, string)
    #ENV['TRAIN_TOPICS'] - integer cutoff for popular topics
    return unless ENV['TRAIN_TOPICS'] && topic.is_popular?(ENV['TRAIN_TOPICS'].to_i)

    return if string.blank?
    c = new
    c.classifier.train("t_#{topic.id.to_s}".to_sym, string)
  end

end
