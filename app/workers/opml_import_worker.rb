class OpmlImportWorker < BaseWorker

  sidekiq_options :queue => :critical

  def perform(dashboard_id)
    dashboard = Dashboard.find(dashboard_id)

    if dashboard.opml_to_import

      dashboard.import_opml_from_url(dashboard.opml_to_import)

      dashboard.opml_to_import = nil
      dashboard.save
    end


  end

end
