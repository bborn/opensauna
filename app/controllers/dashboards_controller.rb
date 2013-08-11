class DashboardsController < SaunaController
  inherit_resources
  respond_to :html, :json, :js, :xml

  skip_before_filter :authenticate_user!, :only => [:post, :posts]

  before_filter :check_owner_or_admin, :only => [:edit, :update, :destroy, :theme, :stats]
  before_filter :check_public, :only => :show

  caches_action :url, :cache_path => Proc.new{|r| request.host+request.fullpath}, :if => Proc.new{|r| !current_user && !params[:dashboard_slug].blank? }, :expires_in => 20.minutes

  layout 'dashboard', :only => ['post', 'posts']

  caches_action [:posts, :post], :cache_path => Proc.new{|r|
    request.host+request.fullpath
  }, :if => Proc.new{|r| !current_user}, :expires_in => 20.minutes

  caches_action :index, :cache_path => Proc.new{|r|
    last_update = current_user.dashboards.max(:updated_at).to_i || ''
    digest = Digest::SHA1.hexdigest("#{last_update}#{current_user.dashboards.count}")
    "#{request.host}#{request.fullpath}#{current_user.id}"
    digest
  }, :expires_in => 1.day


  def post
    @dashboard = Dashboard.where(:slug => params[:dashboard_slug]).first || resource
    @post = @dashboard.posts.find(params[:post_id])
    @the_url = @post.url
    @next = @post.next
    @prev = @post.prev
  end

  def theme
    @dashboard = resource
  end

  def posts
    @dashboard ||= Dashboard.find_by(:slug => params[:dashboard_slug])
    @posts = @dashboard.posts.desc(:created_at).page(params[:page]).per(30)
  end

  def show
    @demo = Dashboard.where(:is_public => true).first

    @dashboard = resource

    @refs = @dashboard.url_references
    @refs = @refs.order_by(:published_at.desc, :created_at.desc, :score.desc)

    # score >= 0 by default
    # score = params[:score].to_i

    classification = params[:class] || (@dashboard.is_recommended? ? 'good' : nil)
    @refs = @refs.any_of({:classification => classification}, {:classification => nil}) unless classification.blank?

    bad_source_ids  = @dashboard.source_ids_not_in_score_deviation_with_floor
    bad_feed_ids    = @dashboard.feed_ids_not_in_score_deviation_with_floor

    @refs = @refs.without_source_or_feed_ids(bad_source_ids, bad_feed_ids)

    @refs = @refs.page(params[:page]).per(30)

    respond_with(@refs)
  end





  def recommended
    @dashboard = current_user.recommended_dashboard
    redirect_to @dashboard
  end

  def new_twitter
    redirect_to user_omniauth_authorize_path(:twitter) and return unless current_user.twitter
    if request.post?
      dashboard = Dashboard.with(safe: true).create(:user_id => current_user.id, :name => "#{current_user.email_or_guest_name.capitalize}'s Twitter")
      if dashboard.valid?
        User.delay.add_twitter_friends_to_dashboard(current_user.id, dashboard.id)

        flash[:notice] = "We're getting your dashboard ready!"
      else
        flash[:notice] = dashboard.errors.full_messages.to_sentence
      end

      redirect_to dashboard
    end
  end

  def new_fb
    redirect_to user_omniauth_authorize_path(:facebook) and return unless current_user.facebook
    if request.post?
      dashboard = Dashboard.with(safe: true).create(:user_id => current_user.id, :name => "#{current_user.email_or_guest_name.capitalize}'s Facebook")
      if dashboard.valid?

        User.delay.add_fb_friends_to_dashboard(current_user.id, dashboard.id)

        flash[:notice] = "We're getting your dashboard ready!"
      else
        flash[:notice] = dashboard.errors.full_messages.to_sentence
      end

      redirect_to dashboard
    end
  end


  def inputs
    @dashboard = resource

    if params[:dashboard] && params[:dashboard][:opml_to_import]
      @dashboard.opml_to_import = params[:dashboard][:opml_to_import]

      @dashboard.save

      OpmlImportWorker.perform_async(@dashboard.id.to_s)
      # OpmlImportWorker.new.perform(@dashboard.id)

      @dashboard.reload

      flash[:notice] = "Thanks, we're processing your import now! They'll appear here in a few minutes."
    end


    if params[:dashboard] && params[:dashboard][:inputs]
      successes, errors = @dashboard.add_inputs(params[:dashboard][:inputs])

      if errors.any?
        flash[:error] = "There were #{errors.size} errors."
      end
      if successes.any?
        @dashboard.queue_worker
        flash[:notice] = "#{successes.size} sources were added! <a href='/dashboards/#{@dashboard.id}'>Click here</a> to view this dashboard".html_safe
      end

    end

    @inputs = @dashboard.feeds + @dashboard.sources

  end


  def create
    create! do |success, failure|
     success.html { redirect_to inputs_dashboard_path(@dashboard) }
     failure.html { render :new}
    end
  end

  def stats
    @dashboard = resource

    @interests = @dashboard.interests

    @source_stats = Statistic.average_source_score_with_deviation(@dashboard)

    @source_range = [(@source_stats[0] - @source_stats[1]), (@source_stats[0] + @source_stats[1])]

    @feed_stats = Statistic.average_feed_score_with_deviation(@dashboard)


    @feed_range = [(@feed_stats[0] - @feed_stats[1]), (@feed_stats[0] + @feed_stats[1])]
  end

  def bookmarklet
    @dashboard = resource
  end

  private

  def collection
    @demo = Dashboard.where(:is_public => true).first

    @dashboards ||= current_user.accessible_dashboards
  end

  def build_resource
    get_resource_ivar || set_resource_ivar(current_user.dashboards.new(params[:dashboard]||{}))
  end

  def check_owner_or_admin
    unless current_user.admin? or current_user.owns?(resource) or resource.shared_with?(current_user)
      flash[:error] = "Sorry, you don't own that dashboard."
      redirect_to dashboards_path and return false
    end
  end

  def check_public
    redirect_to dashboards_path and return false unless resource.is_public? or (current_user && (current_user.owns?(resource) || current_user.admin?) || resource.shared_with?(current_user))
  end


end
