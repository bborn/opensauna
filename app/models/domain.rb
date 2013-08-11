class Domain

  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :urls

  field :name
  validates_uniqueness_of :name

  index({ name: 1 }, { unique: true, name: "name_index"})

  def add_feed_if_popular
    if self.urls.where(:score.gte => 1).count > 5 #five upvoted urls for now
      #try to add this domain as a feed
      Domain.common_dashboard.add_inputs(self.name)
    end
  end

  def self.common_dashboard
    dash = Dashboard.find_or_create_by(:is_public => true, :name => "Common")
    dash
  end


end
