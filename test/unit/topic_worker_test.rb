require 'test_helper'


class TopicWorkerTest < ActiveSupport::TestCase

  setup do
    @dash = create(:dashboard)
    @topic = create(:topic)
    @user = @dash.user
    @urls = [create(:url)]
    @topic.urls = @urls

    Dashboard.expects(:find).with(@dash.id).returns(@dash)

    Topic.expects(:find).with(@topic.id).returns(@topic)

    @dash.expects(:add_urls_async).with(@urls)

    @time = 1.week.ago

  end



  test "should perform its job" do
    @topic.expects(:urls_since).with(@time).returns(@urls)

    worker = TopicWorker.new
    worker.perform(@topic.id, @time, @dash.id)
  end




end
