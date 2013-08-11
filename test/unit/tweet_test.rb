require 'test_helper'

class TweetTest < ActiveSupport::TestCase


  test "can queue a worker" do
    tweet = FactoryGirl.build(:tweet)

    assert_difference "TweetWorker.jobs.size", 1 do
      assert tweet.queue_worker
    end

  end

  test "can be saved with valid attributes" do
    assert !create(:tweet).new_record?
  end

  test "should enqueue itself after being created" do
    tweet = build(:tweet)

    assert_difference "TweetWorker.jobs.size", 1 do
      tweet.save!
    end
  end

  test "should add itself to the URLs tweets array if the URL already exists" do
    tweet = create(:tweet)

    Url.expects(:normalize_url).at_most(3).returns(tweet.cached_urls.first)

    assert_difference "tweet.urls.size", 1 do
      tweet.record_urls
    end

    url = tweet.urls.first

    assert_equal(url.tweets.size, 1)

    tweet2 = create(:tweet, :cached_urls => tweet.cached_urls)
    assert_equal(tweet2.cached_urls, tweet2.cached_urls) #what?!

    assert_difference "Url.count", 0 do
      assert_difference "tweet2.urls.size", 1 do
        tweet2.record_urls
      end
    end

    assert_equal(url.reload.tweets.size, 2)

  end


end
