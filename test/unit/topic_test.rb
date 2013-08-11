require 'test_helper'


class TopicTest < ActiveSupport::TestCase

  test "should initialize new topic with stemming" do

    name = "Walking"
    topic = Topic.find_or_initialize_with_stemming(name)

    assert_equal(topic.name, 'Walking')
    assert_equal topic.alternate_names.first, 'Walk'

    assert topic.new_record?
  end

  test "should find existing topic with stemming" do
    topic = FactoryGirl.create(:topic) #1Sports

    t2 = Topic.find_or_initialize_with_stemming topic.name.stem
    assert !t2.new_record?
    assert_equal(topic, t2)
  end

  test "should stem name" do
    topic = Topic.new :name => 'Walking'
    topic.stem_name.save!
    assert_equal(topic.alternate_names, ['Walk'])
  end

  test "should scope by alternate name" do
    topic = FactoryGirl.create(:topic) #1Sports

    found = Topic.with_alternate_name(topic.name.stem).all

    assert_equal(found, [topic])
  end

  test "should scope by name" do
    topic = FactoryGirl.create(:topic) #1Sports

    found = Topic.with_name(topic.name).all

    assert_equal(found, [topic])
  end

  test "should trigger interest workers" do

    topic = FactoryGirl.create(:topic)
    url   = FactoryGirl.create(:url)

    assert_equal 0, InterestWorker.jobs.size
    Topic.trigger_interest_workers([topic], url)
    assert_equal 1, InterestWorker.jobs.size

  end

  test "should get urls since a point in time" do
    topic = FactoryGirl.create(:topic)
    url   = FactoryGirl.create(:url)
    topic.urls << url

    urls = topic.urls_since(1.year.ago)

    assert_equal urls, [url]
  end

  test 'should determine if it is popular or not' do
    popular = FactoryGirl.create(:topic)
    popular.update_attribute(:urls_count, 10)

    topic = FactoryGirl.create(:topic)
    assert topic.is_popular?
  end


end
