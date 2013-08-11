class User < ActiveRecord::Base

  has_many :authentications, :dependent => :destroy
  include ActionView::Helpers::TextHelper

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :invitable,
    :database_authenticatable,
    :recoverable,
    :rememberable,
    :omniauthable,
    :registerable,
    :trackable

  validates_presence_of :email
  validates_uniqueness_of :email
  validates_presence_of :encrypted_password
  validates_presence_of :password, :if => Proc.new{|u| u.guest? || u.new_record? }
  validates_presence_of :password_confirmation, :if => Proc.new{|u| u.guest? || u.new_record? }
  validates_confirmation_of :password

  # serialize :dashboards_last_read, Hash, {}

  attr_accessible :email, :password, :password_confirmation, :lazy_id, :full_name, :invitation_token

  def dashboards
    Dashboard.where(:user_id => id)
  end

  def posts
    Post.where(:user_id => id)
  end


  def full_name
    read_attribute(:full_name) || email_or_guest_name
  end


  def self.connect_with_twitter_oauth(omniauth, signed_in_resource=nil)

    data = omniauth['extra']

    authentication = signed_in_resource.authentications.where(:provider => omniauth['provider'], :uid => data['uid']).first

    if authentication
      # update the existing auth
      authentication.update_attributes(:provider => omniauth['provider'], :uid => omniauth['uid'], :token => omniauth['credentials']['token'], :secret => omniauth['credentials']['secret'] )
      authentication.save!
    else # Create an auth
      signed_in_resource.authentications.create(:provider => omniauth['provider'], :uid => omniauth['uid'], :token => omniauth['credentials']['token'], :secret => omniauth['credentials']['secret'] )
    end
  end

  def twitter_provider
    auth = self.authentications.where(:provider => 'twitter').first
    auth
  end

  def twitter
    if provider = self.twitter_provider
      client = Twitter::Client.new(:oauth_token => provider.token, :oauth_token_secret => provider.secret)

      if provider.extra.screen_name.blank?
        provider.extra.update_attribute(:screen_name, client.user(provider.uid.to_i).screen_name )
      end

      client
    end
  end

  def facebook_provider
    @facebook_provider ||= authentications.where(:provider => 'facebook').first
  end

  def facebook
    if provider = facebook_provider
      fb = MiniFB.get(provider.token, provider.uid)
    end
  end

  def facebook_friends
    if provider = facebook_provider
      array = MiniFB.get(provider.token, provider.uid, :type => 'friends')['data']
      array
    end
  end

  def facebook_pages
    if provider = facebook_provider
      extra = provider.extra

      res = MiniFB.get(facebook_provider.token, facebook_provider.uid, :type => 'accounts', :params => {:type => "page"})['data']

      me = Hashie::Mash.new({'id' => facebook_provider.uid, 'name' => 'My Facebook Feed', 'access_token' => facebook_provider.token})

      res << me

      extra.update_attribute(:pages, res)

      array = extra.pages
      array.sort_by{|h| extra.managed_page_ids.include?(h.id) ? 0 : 1}
    end
  end

  def facebook_token_for_page(id)
    pages = facebook_pages
    page = pages.select{|h| h.id.eql?(id)}.first
    page.access_token
  end

  def post_to_facebook_page(page_id, params = {})
    return false unless params[:link]
    params = params.reject{|k,v| v.blank? }

    if provider = facebook_provider
      page_token = facebook_token_for_page(page_id)
      array = MiniFB.post(page_token, page_id,
          { :type => 'feed',
            :params => params
          }
        )
    end
  end


  def get_twitter_friends
    if twitter
      twitter_client = twitter
      friend_ids = twitter_client.friend_ids.attrs[:ids]
      friends = twitter_client.users(friend_ids).map(&:screen_name)
    else
      []
    end
  end

  def self.add_twitter_friends_to_dashboard(user_id, dashboard_id)
    user = find(user_id)

    dashboard = user.dashboards.find(dashboard_id)

    dashboard.add_inputs(user.get_twitter_friends)
  end

  def get_fb_friends
    if facebook
      friends = facebook_friends
    else
      []
    end
  end

  def self.add_fb_friends_to_dashboard(user_id, dashboard_id)
    user = find(user_id)

    dashboard = user.dashboards.find(dashboard_id)

    dashboard.add_fb_friends(user.get_fb_friends)
  end

  # def read_dashboard_at(dashboard, time)
  #   dashboards_last_read[dashboard.id.to_s] = time
  #   save
  # end

  def create_first_twitter_dashboard
    if self.twitter
      twitter_client = twitter

      dashboard = Dashboard.with(safe: true).create(:user_id => self.id, :name => "#{email_or_guest_name.capitalize}'s Twitter")

      if dashboard.valid?
        User.delay.add_twitter_friends_to_dashboard(self.id, dashboard.id)
        return dashboard
      else
        return false
      end
    end
  end

  def self.connect_with_fb_oauth(omniauth, signed_in_resource=nil)

    data = omniauth['extra']

    authentication = signed_in_resource.authentications.where(:provider => omniauth['provider'], :uid => omniauth['uid']).first

    if authentication
      # update the existing auth
      authentication.update_attributes(:provider => omniauth['provider'], :uid => omniauth['uid'], :token => omniauth['credentials']['token'], :secret => omniauth['credentials']['secret'] )
      authentication.save!
    else # Create an auth
      signed_in_resource.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'], :token => omniauth['credentials']['token'], :secret => omniauth['credentials']['secret'] )
    end
  end

  def has_social_networks?
    self.authentications.any?
  end

  def accessible_dashboards
    Dashboard.any_of(Dashboard.shared_with(self).selector, Dashboard.where(:user_id => self.id).selector)
  end

  def publishable_dashboards
    accessible_dashboards.where(:custom_url.ne => nil).where(:custom_url.ne => '')
  end

  def guest_email?
    email.include?('@email_address.com')
  end

  def guest?
    guest_email? || !lazy_id.blank?
  end

  def email_or_guest_name
    if guest?
      email[0..10]
    else
      email
    end
  end

  def owns?(dashboard)
    dashboard.user_id === self.id
  end

  def classify(url)
    UserClassifier.classify(self, url)
  end

  def train(sentiment, url)
    UserClassifier.train(sentiment, url, self)
  end

  def scores
    Score.where(:user_id => self.id)
  end

  def interests
    self.interest.topics
  end

  def interest
    Interest.find_or_create_by(:user_id => self.id) || nil
  end

  def recommended_dashboard
    @recommended_dashboard ||= begin
      d = Dashboard.find_or_initialize_by(:is_recommended => true, :user_id => self.id)
      d.name ||= "#{self.full_name}'s Recommendations"
      d.custom_url = self.email.split('@')[0].parameterize
      d.save
      d
    end
  end

  def toggle_topic(topic_id)
    self.interest.toggle_topic(topic_id)
  end

  def add_topics(topics)
    self.interest.add_topics(topics)
  end

  def remove_topics(topics)
    topics.each do |t|
      self.interest.topics.delete(t)
    end
  end

  def bayes_keywords
    c = UserClassifier.new(self.id)
    words = c.database["user_#{self.id}_word_frequencies"].find
    results = {'good' => [], 'bad' => []}

    words.each do |h|
      if h['good']
        results['good'] << h
      end

      if h['bad']
        results['bad'] << h
      end
    end

    return results
  end


  def recommended_urls_since(since = 1.day.ago)
    urls = Url.where(:title.ne => '')
    urls = urls.with_images_or_video_or_body
    urls = urls.where(:last_processed_at.ne => nil)
    urls = urls.where(:score.gte => 0)

    urls = urls.where(:created_at.gt => since)

    topics = self.interests

    urls = urls.any_in(:topic_ids => topic_ids )

    urls
  end

  def post_to_twitter(post)
    tweet = "#{truncate(post.title, :length => 50)} #{post.full_post_url} "
    response = twitter.update(tweet)
  end

  def self.post_to_twitter(user_id, post_id)
    user = User.find(user_id)
    post = Post.find(post_id)
    user.post_to_twitter(post)
  end

  def self.post_to_facebook_page(user_id, page_id, post_id)
    user = User.find(user_id)
    post = Post.find(post_id)
    params = {
      :message => post.title,
      :link => post.full_post_url,
      :picture => post.image
    }
    response = user.post_to_facebook_page(page_id, params)
  end

  def last_published_post_datetime
    posts.max(:publish_at)
  end

  def post_publish_at_default
    now = Time.now
    last = last_published_post_datetime
    if last
      dist = (((last.to_time - now))/1.hour)
      if dist.to_f < -1
        0
      else
        ((dist.hours + 30.minutes)/1.hour).ceil
      end
    else
      0
    end
  end


  def self.check_for_processed_dashboards(user_id, dashboard_id)
    dashboard = Dashboard.find(dashboard_id)
    user = User.find(user_id)

    if dashboard.empty? or dashboard.processing?
      User.delay_for(20.minutes, :retry => false, :queue => :critical).check_for_processed_dashboards(user_id, dashboard_id)
      return false
    else
      Mailer.initial_dashboard_processing_complete(dashboard).deliver
      return true
    end
  end


  rails_admin do

    edit do
      exclude_fields :password, :password_confirmation
    end


    list do
      include_fields :id

      field :full_name do
        pretty_value do
          bindings[:object].full_name
        end
      end
      field :dashes do
        pretty_value do
          bindings[:object].dashboards.count.to_s
        end
      end

      include_fields :created_at, :last_sign_in_at

    end
  end


end
