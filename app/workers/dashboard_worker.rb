class DashboardWorker < BaseWorker

  sidekiq_options :unique => true,
                  :unique_job_expiration => (120 * 60)

  def perform(id)

    dash = nil

    dash = Dashboard.find(id)

    dash.process_inputs

  end



end
