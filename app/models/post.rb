require 'open-uri'

class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  field :user_id, :type => Integer
  field :title
  field :body
  field :images, :type => Array, :default => []
  field :publish_at, :type => DateTime
  # has_many :images, :validate => false, :as => :attachable

  belongs_to :url
  belongs_to :dashboard

  validates_presence_of :title, :body, :dashboard_id
  attr_accessor :publish_facebook_page_ids, :publish_to_twitter, :publish_at_interval

  def user
    User.find(user_id)
  end

  before_save do |post|
    post.publish_at ||= (post.publish_at_interval.to_i||0).hours.from_now
  end


  after_create do |post|
    post.publish_facebook_page_ids.each do |page_id|
      User.delay_until(post.publish_at).post_to_facebook_page(user.id, page_id, post.id)
    end unless publish_facebook_page_ids.blank?

    User.delay_until(post.publish_at).post_to_twitter(user.id, post.id) if publish_to_twitter

  end

  def update_images_from_url
    if url.images.any?
      self.images = url.image_urls
      save
    end
  end


  def full_post_url
    dash = self.dashboard
    url = if !dash.custom_url.blank?
      if dash.custom_url.include?('.')
        "http://#{dash.slug}/p/#{self.id}"
      else
        "http://#{dash.slug}.#{ENV['BASE_HOST_NAME']}/p/#{self.id}"
      end
    else
      "http://#{ActionMailer::Base.default_url_options[:host]}/p/#{self.id}"
    end
    url
  end

  def overridden_url
    u = url
    u.title = self.title
    u.body  = self.body
    u.images = self.images
    u
  end

  def in_sequence(direction)
    posts = Post.where(:dashboard_id => dashboard_id)

    if direction.eql?('next')
      posts = posts.where(:_id.gt => self.id).order_by(:_id.asc).limit(1)
    else
      posts = posts.where(:_id.lt => self.id).order_by(:_id.desc).limit(1)
    end
    posts.first

  end

  def next
    in_sequence('next')
  end

  def prev
    in_sequence('prev')
  end

  def image
    images.any? && images.first
  end

  def video_embed
    url.video_embeds && url.video_embeds.first
  end

  def favicon
    url.favicon
  end

  def domain_name
    url.domain && url.domain.name
  end

  def self.publish_at_options
    times = (1..8).collect{|t| ["#{t} hours from now", t]}
    times.unshift ['Now', 0]
    times
  end

end
