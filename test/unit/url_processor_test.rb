require 'test_helper'


class UrlProcessorTest < ActiveSupport::TestCase

  setup do

    @meta = {
      :titles =>  ['title1', 'title2'],
      :title => 'title1',
      :lede => 'this is the lede',
      :url => 'http://bit.ly/link',
      :favicon => 'favicon.ico',
      :datetime => Date.parse('Sat, 26 Feb 2011 08:59:10 -0600'),
      :body => 'the body of the post. it needs to. have at least. five sentences. to be processed by calais. another thing.',
      :html_body => '<p>the the body of the post. it needs to. have at least. five sentences. to be processed by calais. another thing.</p>',
      :images => ['http://bit.ly/image1', 'http://bit.ly/image2'],
      :videos => ['<object></object>'],
      :description => 'description of the page',
      :keywords => [['key', 3], ['words', 3], ['here', 3] ]
    }

    @mock_doc = mock('Pismo::Document')
    @meta.each{|k,v|
      @mock_doc.stubs(k).returns(v)
    }

    @short_url = 'http://bit.ly/link'
    @expanded_url = 'http://www.example.com/path/to/url'

    @url = Url.new(:url => @short_url)

    resp = mock("Object")
    resp.stubs(:socialtags).returns([{ 'name' => 'Internet', 'importance' => 1}])
    Calais.stubs(:process_document).returns(resp)

    MiniFB.stubs(:get).returns({})

  end

  should  "set its domain" do
    @url.set_domain!
    assert_equal 'bit.ly', @url.domain.name
  end

  should "process its URL by getting meta data about the page using Pismo" do

    @url.expects(:normalize_url!)
    @url.expects(:set_domain!)

    Pismo::Document.
      expects(:new).
      with(@short_url, {:image_extractor => true, :min_image_width => 200, :min_image_height => 200}).
      returns(@mock_doc)

    @url.stubs(:scrape_images).returns(true)

    @url.expects(:save).returns(true)

    @url.expects(:process_calais)

    @url.process_url(true)

    @meta.except(:keywords, :videos, :images).each{|k,v|
      assert_equal @url.send(k), v
    }

    assert_equal @url.keywords, @meta[:keywords].map{|arr| {name: arr.first.downcase, importance: arr.last} }

    assert_equal @url.keyword_list, ['key', 'words', 'here']
  end


  should "tokenize body" do
    text = "This is some text. And here is a sentence."

    count = @url.count_sentences(text)
    assert_equal count, 2
  end

  should "use calais API to generate topics" do
    t = mock('Topic')
    t.stubs(:find_or_initialize_with_stemming => t, :id => 1)

    Topic.expects(:find_or_initialize_with_stemming).with('Internet').returns(t)

    @url.stubs(:topics).returns([])

    @url.expects(:train_topics)

    @url.process_calais("some text")

    assert_equal @url.topics, [t]
  end

  should "rescue Calais error and use train TopicClasifier if ENV[TRAIN_TOPICS] is set" do
    ENV['TRAIN_TOPICS'] = 100

    topic = create :topic

    Calais.stubs(:process_document).raises('Error')

    nodes = [topic.id]

    TopicClassifier.expects(:classify).with(@url.to_bayes).returns(nodes)

    @url.process_calais("some text")
    assert_equal [topic], @url.topics

    ENV['TRAIN_TOPICS'] = nil
  end

  should "process vimeo url" do
    @url.url = "http://vimeo.com/video/1234"
    @url.set_domain!

    doc = mock()
    doc.stubs(:html => "html string")

    extracted_content = mock()
    extracted_content.stubs(:video_embed => "embed", :content => "description")

    extractula_response = mock()
    extractula_response.stubs(:extract => extracted_content)

    nokigiri_response = mock()
    nokigiri_response.stubs(:at).with('iframe').returns({'src' => 'video_src'})

    Nokogiri.stubs(:HTML).returns(nokigiri_response)

    Extractula::Vimeo.expects(:new).with("http://vimeo.com/video/1234", doc.html).returns(extractula_response)

    @url.process_videos(doc)

    assert_equal @url.video, 'video_src'
    assert_equal @url.description, 'description'

  end


 should "process youtube url" do
    @url.url = "http://youtube.com/video/1234"
    @url.set_domain!

    doc = mock()
    doc.stubs(:html => "html string")

    extracted_content = mock()
    extracted_content.stubs(:video_embed => "embed", :content => "description")

    extractula_response = mock()
    extractula_response.stubs(:extract => extracted_content)

    nokigiri_response = mock()
    nokigiri_response.stubs(:at).with('iframe').returns({'src' => 'video_src'})

    Nokogiri.stubs(:HTML).returns(nokigiri_response)

    Extractula::YouTube.expects(:new).with("http://youtube.com/video/1234", doc.html).returns(extractula_response)

    @url.process_videos(doc)

    assert_equal @url.video, 'video_src'
    assert_equal @url.description, 'description'

  end

  should "train topics" do
    # @url.topics.expects(:each)

    # TopicClassifier.expects(:train).with(Topic.last.id, @url.to_bayes_hash)
  end

  should "check facebook shares" do
    MiniFB.expects(:get).with('166820163376988|QGkKj8tmuzEzc-8Tg4-YdNDUGD0', @url.url).returns({'shares' => 12345})
    assert_equal @url.get_facebook_shares, 12345
  end

  should "clean up with custom cleaners" do
    u = Url.new :url => "http://instagram.com/p/1234"
    u.body = "bruno is using Instagram"
    cleaner = CustomUrlCleaner.new(u)
    u = cleaner.clean_up

    assert_equal(u.body, 'Instagram photo')
  end

  should "scrape images" do
    @url.cached_images = ['http://go.com/image.jpg', nil, 'http://go.com/image.jpg']

    iu = mock("ImageUploader")
    iu.stubs(:download! => true, :store! => true, :url => 'http://assets.sauna.io/image.jpg')
    ImageUploader.stubs(:new).returns(iu)

    @url.scrape_images
  end


end
