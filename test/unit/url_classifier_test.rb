require 'test_helper'


class UrlClassifierTest < ActiveSupport::TestCase

  # test "should return its corpus" do
  #   dashboard = create(:dashboard)
  #   BayesMotel::Persistence::MongoidInterface.expects(:new).with("dashboard_#{dashboard.id.to_s}")
  #   c = UrlClassifier.classifier(dashboard.id)
  #   assert_equal(c.class, BayesMotel::Corpus)
  # end

  test "should perform its job and classify or train a URL" do
    url = create :url
    url.expects(:score_class).returns('good')
    dashboard = create :dashboard

    Url.expects(:find).twice.with(url.id).returns(url)

    worker = UrlClassifier.new(dashboard.id)

    worker.perform(url.id, dashboard.id, 'classify')

    worker.perform(url.id, dashboard.id, 'train')

    keywords = dashboard.reload.bayes_keywords.values.flatten
    url.title.split(" ").each do |word|
      w = word.stem.downcase
      assert keywords.include?(w), "#{word} not found in training corpus"
    end

  end


  test "classify a URL" do
    url = create :url
    dashboard = create :dashboard

    result = UrlClassifier.classify(url, dashboard.id)
    assert_equal result, nil
  end

  # test "train the classifier" do
  #   url = create :url
  #   dashboard = create :dashboard

  #   corpus = mock('BayesMotel::Corpus')
  #   BayesMotel::Corpus.expects(:new).returns(corpus)
  #   corpus.expects(:train).with(url.to_bayes_hash, 'good').returns(true)

  #   result = UrlClassifier.train('good', url, dashboard.id)

  #   assert result
  # end

  test 'train and classify some URLS' do
    url = create :url
    dashboard = create :dashboard

    # puts "url: #{url.to_bayes.inspect}"
    UrlClassifier.train(:good, url, dashboard.id)

    bad_url = Url.new :url => "http://example.com"
    bad_url.title = "cnn makes good news"
    bad_url.save!
    # puts "bad_url: #{bad_url.to_bayes.inspect}"
    UrlClassifier.train(:bad, bad_url, dashboard.id)

    new_url = Url.create! :url => "http://example.com"
    new_url.title = "cnn news is nice"
    new_url.save!
    # puts "new_url: #{new_url.to_bayes.inspect}"
    result = UrlClassifier.classify(new_url, dashboard.id)
    assert_equal :bad, result


    new_url = Url.create! :url => "http://example.com"
    new_url.title = "post titles are for blogs"
    new_url.save!
    # puts "new_url: #{new_url.to_bayes.inspect}"
    result = UrlClassifier.classify(new_url, dashboard.id)
    assert_equal :good, result

  end









end
