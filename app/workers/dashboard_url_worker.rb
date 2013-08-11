class DashboardUrlWorker < BaseWorker
  sidekiq_options :retry => false,
                  :backtrace => 2,
                  :queue => :dashboard_urls,
                  :unique => true

  def perform(dashboard_id, url_id)
    dashboard = Dashboard.find dashboard_id
    url = Url.find url_id

    dashboard.add_url(url)
  end


end
