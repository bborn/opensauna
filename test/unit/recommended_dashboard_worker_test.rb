require 'test_helper'


class RecommendedDashboardWorkerTest < ActiveSupport::TestCase

  setup do
    @time = 1.week.ago
    @dash = create(:dashboard)
    @user = @dash.user
    @topic = create(:topic)
    @urls = [create(:url)]

    @topic.urls = @urls

    Dashboard.expects(:find).with(@dash.id).returns(@dash)

    User.expects(:find).with(@dash.user_id).returns(@user)
  end

  test "should perform its job" do
    TopicWorker.expects(:perform_async)
    mock_interest = mock('Interest')
    mock_interest.stubs(:topic_ids => [@topic.id])

    @user.expects(:interest).returns(mock_interest)
    worker = RecommendedDashboardWorker.new
    worker.perform(@dash.id, @time)
  end


end
