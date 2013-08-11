class Score
  include Mongoid::Document
  include Mongoid::Timestamps

  field :user_id, :type => Integer
  field :url_id
  field :dashboard_id
  field :domain_id
  field :score, :type => Integer, :default => 0

  belongs_to :domain
  belongs_to :dashboard
  belongs_to :url

  index({ url_id: 1, user_id: 1 }, { unique: true, name: "url_user_index", drop_dups: true})

  validates_presence_of :user_id, :url_id
  validates_uniqueness_of :url_id, :scope => :user_id

  before_create do |record|
    if record.url && record.url.domain
      record.domain_id = record.url.domain.id
    end
  end

  def self.score!(user_id, url_id, dashboard_id = nil, string)
    change = string.to_f

    #first create the score
    s = Score.find_or_initialize_by(:user_id => user_id, :url_id => url_id, :dashboard_id => dashboard_id)
    s.score += change
    s.save!

    #now run some callbacks
    s.score_url(change)
    s.update_url_references unless s.score.zero?

    s.domain.add_feed_if_popular if s.domain

    s.train_classifiers

    # if @the_url.score > 0
    # #   current_user.add_topics(@the_url.topics)
    # else
    # #   current_user.remove_topics(@the_url.topics)
    # end

    return s
  end

  def train_classifiers
    # UrlClassifier.perform_async(self.to_param, dashboard_id, 'train')
    dashboard.train(url.score_class, url)   if dashboard
    user.train(url.score_class, url)        if user
  end


  def update_url_references
    if dashboard
      reference = dashboard.url_references.find_by(:url_id => url_id)

      if score < 0
        reference.destroy
      else
        reference.update_attributes(:classification => url.score_class.to_sym, :score => score)
      end
    end
  end

  def score_url(change)
    if dashboard_id
      url.change_score(change, dashboard_id)
    else
      url.score += change
      url.save
    end
  end

  def user
    User.find(user_id)
  end

  def self.retrain_from_user_scores(user)
    # BaseClassifier.new("user_#{user.id}").storage.drop_tables
    # UserClassifier.new(user.id).storage.reset
    scores = user.scores
    scores.each do |score|
      score.train_classifiers
    end
  end


end

