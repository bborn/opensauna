class Interest
  include Mongoid::Document
  include Mongoid::Timestamps

  has_and_belongs_to_many :topics, :validate => false
  field :user_id, :type => Integer
  validates_presence_of :user_id

  def queue_recommendation_worker
    RecommendedDashboardWorker.perform_async(user.recommended_dashboard.id.to_s, 3.days.ago)
  end

  def user
    User.find(user_id) || nil
  end

  def add_topics(new_topics)
    topics << new_topics
  end

  def toggle_topic(topic_id)
    if topic = Topic.where(:id => topic_id).first
      if topics.include?(topic)
        topics.delete(topic)
      else
        topics << topic
      end
    end

    queue_recommendation_worker
  end

end
