class ScheduledWorker < BaseWorker
  sidekiq_options :queue => :critical

  def perform


    users = User.order('last_sign_in_at DESC').where("last_sign_in_at > ?", 2.weeks.ago).each do |user|
      dashes = user.dashboards.each {|dash|
        dash.queue_worker
      }
    end

  end



end
