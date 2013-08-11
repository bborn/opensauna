class UrlsController < SaunaController
  inherit_resources

  respond_to :html, :xml, :json, :js, :bookmark
  skip_before_filter :authenticate_user!, :only => [:browse]

  defaults :resource_class => Url, :collection_name => 'urls', :instance_name => 'the_url'
  caches_action :browse, :cache_path => Proc.new{|r| request.host+request.fullpath}, :if => Proc.new{|r| !current_user}, :expires_in => 20.minutes

  before_filter :require_admin, :except => [:create, :browse, :score, :new, :story_panel, :share_panel]

  def index
    @urls = Url.desc(:created_at).page(params[:page]).per(50)

    respond_with(@urls)
  end


  def create

    @the_url = Url.find_or_initialize_by_url(params[:url].delete(:url))
    dashboard_ids = params[:url].delete(:dashboard_ids)

    images = params[:url][:cached_images]
    old_images = @the_url.cached_images #if the URL already exists

    @the_url.attributes = params[:url]

    @the_url.dashboard_ids << dashboard_ids
    @the_url.cached_images = old_images + images

    # create!
    @the_url.save

    if params[:create_post]
      @post = current_user.posts.new(params[:url].merge(params[:post]||{}))
      @post.url = @the_url
      @post.images = @the_url.image_urls
      @post.body = params[:url][:lede]
      @post.dashboard = current_user.dashboards.find(dashboard_ids)
      @post.save
    end
  end

  def story_panel
    @the_url = Url.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def share_panel
    @url = Url.find(params[:id])
    @post = current_user.posts.new(params[:post]||{})
    @post.url = @url

    @post.dashboard_id = params[:dashboard_id]

    @post.title  = @url.title
    @post.body   = "<blockquote>#{@url.description || @url.lede}</blockquote><p></p>"
    @post.images = @url.image_urls

    respond_to do |format|
      format.js {
        render 'posts/new'
      }
    end

  end

  def browse
    # unless params[:dashboard_slug] || params[:keyword] || params[:user_id]
    #   redirect_to dashboards_path and return if signed_in?
    #   render :template => 'sauna/home' and return
    # end

    @urls = Url.where(:title.ne => '').desc(:created_at)

    @urls = @urls.with_images_or_video_or_body

    if params[:dashboard_slug]
      @dashboard = Dashboard.where(:slug => params[:dashboard_slug]).first
      dashboard_ids = [@dashboard.id]
      @urls = @urls.any_in(:dashboard_ids => dashboard_ids)
    else
      dashboard_ids = Dashboard.public_dashboard_ids(current_user)
    end

    @urls = @urls.where(:last_processed_at.ne => nil)

    if params[:topic]
      @topic = Topic.where(:name => params[:topic]).first
      @urls = @urls.any_in(:topic_ids => [@topic.id])
    elsif params[:keyword]
      @urls = @urls.any_in(:keyword_list => [params[:keyword]])
    elsif params[:user_id] && (@topics = current_user.interests) && !@topics.blank?
      @topic_ids = @topics.map(&:id)
      @urls = @urls.any_in(:topic_ids => @topic_ids )
      @urls = @urls.where(:score.gte => 0)
    else
      @urls = @urls.where(:score.gte => params[:score].to_i)
    end

    @urls = @urls.page(params[:page]).per(30)

    respond_with(@urls)
  end

  def score
    @the_url = Url.find(params[:id])

    Score.score!(current_user.id, @the_url.id, params[:dashboard_id], params[:score] )

    respond_to do |format|
      format.html {
        redirect_to url_path(@the_url)
      }
      format.js
    end
  end

  def show
    @the_url = Url.find(params[:id])

    @the_url.process_url if params[:reprocess]

    respond_with(@the_url)
  end

end

