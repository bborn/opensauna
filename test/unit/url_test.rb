require 'test_helper'

class UrlTest < ActiveSupport::TestCase

  should "cache the sources" do
    u = Url.new :url => "http://bit.ly"
    source = create(:source, :dashboards => [create(:dashboard)])
    u.tweets << create(:tweet, :sources => [source])
    u.save!

    assert_equal u.cached_sources, [source.id]
  end

  should "cache the dashboard ids" do
    u = Url.new :url => "http://bit.ly"
    d1 = create(:dashboard)
    d2 = create(:dashboard)
    source1 = create(:source, :dashboards => [d1])
    source2 = create(:source, :dashboards => [d2])

    u.tweets << create(:tweet, :sources => [source1, source2])
    u.save!

    assert_equal u.dashboard_ids, [d1.id, d2.id]
  end

  test 'provide a hash for bayes classification' do
    u = Url.new({
        :url => "http://example.com/post/path/1234",
        :title => "Some & junk",
        :body => "lorem ipsum lorem",
        :keyword_list => ['sporting', 'words']
      }
    )
    u.set_domain!

    actual = u.to_bayes

    assert_equal("Some & junk sporting words", actual)

  end


  test "should check facebook shares" do
    u = Url.new :url => "http://oprah.com"

    MiniFB.expects(:get).with('166820163376988|QGkKj8tmuzEzc-8Tg4-YdNDUGD0', u.url).returns({'shares' => 12345})
    assert_equal u.get_facebook_shares, 12345
  end

  test "should clean up with custom cleaners" do
    u = Url.new :url => "http://instagram.com/p/1234"
    u.body = "bruno is using Instagram"
    cleaner = CustomUrlCleaner.new(u)
    u = cleaner.clean_up

    assert_equal u.body, 'Instagram photo'
  end

  test "should scrape images" do
    u = create :url

    assert_equal u.cached_images, ['http://bit.ly/image1', 'http://bit.ly/image2']

    u.scrape_images
    u.save!
    assert u.images.first.file.url
  end

  test "should update post images after saving" do
    url  = create :url
    post = create :post
    post.url = url
    post.save

    url.cached_images = ['https://www.google.com/images/srpr/logo3w.png']
    url.scrape_images

    assert_equal(post.reload.images, url.image_urls)
  end



  # This is just for experimenting, can't rely on the classification to test
  # test 'bayes classification' do
  #   mm = BayesMotel::Persistence::MongoidInterface.new("test")
  #   c = BayesMotel::Corpus.new(mm)

  #   categories = {:good => ["sports", 'entertainment'], :bad => ["politics", "business"]}

  #   tests = {}
  #   categories.each do |sentiment, categories|
  #     categories.each do |category|
  #       feed = Feed.new :uri => "http://rss.news.yahoo.com/rss/#{category}"

  #       entries = Feedzirra::Feed.fetch_and_parse(feed.uri).entries

  #       tests[sentiment] ||=[]
  #       tests[sentiment] << entries.pop

  #       entries[0..10].each do |item|
  #         u = url_from_feed_item(item)
  #         c.train( u.to_bayes_hash , sentiment)
  #       end
  #     end
  #   end


  #   tests.each do |sentiment, items|
  #     items.each do |item|
  #       u = url_from_feed_item(item)

  #       puts '-------'
  #       puts u.to_bayes_hash
  #       score = c.classify(u.to_bayes_hash)

  #       puts "#{sentiment} => #{score}"
  #       puts '-------'

  #       assert_equal sentiment, score.first
  #     end
  #   end

  # end

  private

  def url_from_feed_item(item)
    u = Url.new
    u.url = item.url
    u.set_domain!
    u.title   = item.title
    u.body    = item.content
    u
  end


end
