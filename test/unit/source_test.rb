require 'test_helper'


class SourceTest < ActiveSupport::TestCase

  setup do
    @source = create(:source, :dashboards => [create(:dashboard)])
  end

  test "can belong to many dashboards" do
    @source.dashboards << create(:dashboard)
    assert_equal @source.dashboards.count, 2
  end


  test "determine if a string is a screenname not a feed" do
    Twitter.expects(:user).once.returns(true)
    assert_equal Source.screenname?('curbly'), 'curbly'

    Twitter.expects(:user).twice.raises(Twitter::Error::NotFound)
    assert_equal Source.screenname?('curbly.com'), false
    assert_equal Source.screenname?('http://curbly.com'), false

  end

  test "can be saved" do
    assert Source.create!(:name => '@twtesttername', :dashboards => [create(:dashboard)])
  end

  test "can process itself" do
    @source.stubs(:fb_uid => false)
    @source.expects(:process_tweets).once.returns(true)
    @source.process

    @source.stubs(:fb_uid => true)
    @source.expects(:process_fb_posts).once.returns(true)
    @source.process
  end

  test "process tweets" do
    @source.expects(:last_fetched_at).twice.returns(10.hours.ago)
    @source.expects(:fetch_tweets).returns(['array', 'of', 'tweets'])
    @source.expects(:record_tweets).returns(true)

    @source.process_tweets
  end

  test 'process fb posts' do
    @source.fb_uid = 1234
    @source.save!
    @source.expects(:last_fetched_at).twice.returns(10.hours.ago)

    provider = mock()
    provider.stubs(:token => 1234, :uid => 1234)

    Authentication.expects(:find_by_uid).with(1234).returns(provider)

    MiniFB.expects(:get).returns({'data' => ['array', 'of', 'posts']})
    @source.expects(:record_posts).returns(true)

    @source.process_fb_posts

  end

  test "fetch recent tweets for an @username" do
    Twitter.expects(:user_timeline).with(@source.name, {:include_entities => true}).returns(['array', 'of', 'tweets'])
    assert !@source.fetch_tweets.empty?
  end

  test "record tweets" do
    tweet = Hashie::Mash.new('id_str' => '123', 'text'    => 'tweet text', 'created_at' => 1.day.ago, 'urls' => [{'url' => 'http://example.com'}] )

    tweets = [tweet]

    @source.tweets.expects(:create!).once

    @source.record_tweets(tweets)
  end

  test "record fb posts" do
    post  = {'message' => "facebook message", 'link' => 'http://link.com', 'caption' => "caption from facebook"}
    posts = [post]

    uri = mock()
    PostRank::URI.expects(:extract).returns([uri])

    url = mock('Url')
    url.stubs(:id => 1, :fb_sources => [], :save => true)
    url.expects(:with).with(safe: true).returns(url)
    url.fb_sources.expects(:<<).with(@source).returns(true)

    Url.expects(:find_or_initialize_by_url).returns(url)

    @source.record_posts(posts)
  end

  test "record tweets when they already exist" do
    tweet = Hashie::Mash.new('id_str' => '123', 'text' => 'tweet text', 'created_at' => 1.day.ago, 'urls' => [{'url' => 'http://example.com'}])
    tweets = [tweet]
    @source.tweets.expects(:create!).once
    @source.record_tweets(tweets)

    another_source = create(:source, :dashboards => [create(:dashboard)])

    assert_difference "another_source.tweets.size", 1 do
      another_source.record_tweets(tweets)
    end
  end


end


