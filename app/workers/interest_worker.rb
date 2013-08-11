class InterestWorker < BaseWorker
  sidekiq_options :unique => true

  def perform(topic_ids, url_id)

    #find all interests that include these topics
    interests = Interest.any_in(:topic_ids => topic_ids)

    interests.map(&:user_id).uniq.each do |uid|

      if user = User.find(uid)
        if dash = user.recommended_dashboard
          url = Url.find(url_id)

          dash.add_url_async(url)

        end
      end
    end

  end

end
