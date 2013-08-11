class Mailer < ActionMailer::Base

  def initial_dashboard_processing_complete(dashboard)
    @dashboard = dashboard

    @heading = "Yay! We've finished processing your #{dashboard.name} dashboard"

    @url = dashboard_url(@dashboard)

    mail(:to => @dashboard.user.email,
         :subject => "Your Sauna dashboard has been processed")
  end


end
