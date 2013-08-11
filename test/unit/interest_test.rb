require 'test_helper'


class InterestTest < ActiveSupport::TestCase

  should "add topics" do

    interest = Interest.create! :user_id => 1
    topic = FactoryGirl.create(:topic)

    interest.add_topics([topic])

    assert_equal( interest.topics.last, topic)
  end


  test "should get user" do
    user = FactoryGirl.create(:user)

    interest = Interest.create! :user_id => user.id

    assert_equal(user, interest.user)
  end

  test "should toggle topic" do
    topic = FactoryGirl.create(:topic)

    interest = Interest.new :user_id => FactoryGirl.create(:user).id

    interest.toggle_topic(topic.id)

    assert_equal(interest.topics.last, topic)

    interest.toggle_topic(topic.id)

    assert_equal(interest.topics.last, nil)

  end


end
