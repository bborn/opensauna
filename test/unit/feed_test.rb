require 'test_helper'

class FeedTest < ActiveSupport::TestCase

  setup do
    @dashboard = create(:dashboard)
    @feed = create(:feed, :dashboards => [@dashboard])
  end

  test "can belong to many dashboards" do
    @feed.dashboards << create(:dashboard)
    assert_equal @feed.dashboards.count, 2
  end

  test "determine if a string is a feed" do
    string = 'curbly.com'
    feed = mock()
    feed.stubs(:uri => 'http://curbly.com/rss')

    agent = mock()
    Mechanize.expects(:new).returns(agent)
    agent.expects(:get).returns(feed)

    assert_equal Feed.feed?(string), 'http://curbly.com/rss'

    PostRank::URI.expects(:extract).with('@twitteruser').returns([])
    assert_equal Feed.feed?('@twitteruser'), false
  end

  test "get and change score for a dashboard" do
    feed2 = create(:feed, :dashboards => [@dashboard])
    feed2.change_score(-2, @dashboard.id)
    @feed.change_score(1, @dashboard.id)

    score = @feed.score_for(@dashboard.id)
    assert_equal @feed.score_class(@dashboard), 'neutral'
    assert_equal score, 1

    feed3 = create(:feed, :dashboards => [@dashboard])
    feed3.change_score(10, @dashboard.id)
    assert_equal feed3.score_class(@dashboard), 'good'

    feed4 = create(:feed, :dashboards => [@dashboard])
    feed4.change_score(-20, @dashboard.id)
    assert_equal feed4.score_class(@dashboard), 'bad'
  end


  test 'process feed' do
    feed = stub(:title => "Title", :etag => '1234', :last_modified => '2012-01-01', :last_fetched_at => 30.days.ago)

    entry = stub(:url => "http://example.com/p/1234.html", :title => "Entry title", :summary => "Summary", :content => 'content', :published => '2012-01-01')
    entries = [entry]
    feed.expects(:entries).returns(entries)
    feed.expects(:sanitize_entries!).returns(true)

    Feedzirra::Feed.expects(:fetch_and_parse).returns(feed)

    assert_difference "@feed.urls.count", 1 do
      @feed.process_feed
    end

  end

end
