class AdminController < SaunaController
  before_filter :require_admin


  def home
  end

  def purge_old_urls
    Url.destroy_urls_before(params[:date] || 1.week.ago)
    redirect_to :action => :index
  end

  def reprocess
    flash[:notice] = "Reprocessing #{params[:type]}"

    case params[:type]
      when 'sources'
        if params[:id]
          s = Source.find(params[:id])
          s.queue_worker
        else
          SourceWorker.delay.process_all
        end
      when 'feeds'
        if params[:id]
          f = Feed.find(params[:id])
          f.queue_worker
        else
          FeedWorker.delay.process_all
        end
      when 'urls'
        if params[:id]
          u = Url.find(params[:id])
          u.queue_worker(true)
        else
          UrlWorker.delay.process_all
        end
      when 'tweets'
        if params[:id]
          t = Tweet.find(params[:id])
          t.queue_worker
        else
          TweetWorker.delay.process_all
        end
      when 'dashboards'
        dashboard = Dashboard.find(params[:id])
        dashboard.queue_worker
      when 'all'
        AppWorker.process_all
    end

    if params[:type] && params[:id]
      redirect_to :controller => params[:type], :action => :show, :id => params[:id]
    else
      redirect_to :action => "home"
    end

  end


end
