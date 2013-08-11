class TopicsController < SaunaController
  before_filter :require_admin, :only => [:user_profile]

  def choose
    @user = current_user

    unless params[:q] && !params[:q].blank?
      @topics = Topic.desc(:featured, :urls_count).limit(12)
    else
      reg = /#{Regexp.escape(params[:q])}/i
      @topics = Topic.where(name: reg).limit(12)
    end
    @topics = (@topics | @user.interests).uniq

    if request.post?
      if params[:clear_all]
        current_user.interest.topics.clear
        current_user.interest.queue_recommendation_worker
      else
        current_user.toggle_topic(params[:topic_id])
      end
    end

    respond_to do |format|
      format.html
      format.js
    end

  end


  def user_profile
    @user = User.where(:id => params[:id]).first || current_user
    @scores = @user.scores

    # Score.retrain_from_user_scores(current_user)
  end

end
