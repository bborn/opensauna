require 'test_helper'


class UserTest < ActiveSupport::TestCase

  test "post publish_at default" do

    user = create :user
    post = create :post
    post.user_id = user.id
    post.publish_at = 55.minutes.from_now
    post.save!

    assert_equal post.publish_at.to_i, user.last_published_post_datetime.to_i

    assert_equal user.post_publish_at_default, 2

    post.publish_at = 15.minutes.ago
    post.save!
    assert_equal user.post_publish_at_default, 1


    post.publish_at = 35.minutes.ago
    post.save!
    assert_equal user.post_publish_at_default, 0
  end

  test 'check for processed dashboards, reschedule if not complete' do
    dash = create :dashboard
    user = dash.user

    assert_equal User.check_for_processed_dashboards(user.id, dash.id), false
  end

  test 'should send notification when dashboard has urls' do
    dash = create :dashboard
    url = create :url
    dash.add_url(url)

    user = dash.user

    assert_difference "ActionMailer::Base.deliveries.count", 1 do
      assert_equal User.check_for_processed_dashboards(user.id, dash.id), true
    end
  end


end
