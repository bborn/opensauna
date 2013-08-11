require 'timeout'



module UrlProcessor

  def set_domain!
    self.domain  =   Domain.find_or_create_by(:name => PostRank::URI.normalize(url).normalized_host)
  end

  def process_keywords(doc)
    self.keywords     = doc.keywords.map{|arr| {name: arr.first.downcase, importance: arr.last} }
    self.keyword_list = self.keywords.map{|h| h[:name] if h[:importance] > 2}.compact
  end


  def process_title(doc)
    self.titles       = doc.titles unless doc.titles.blank?
    self.title        = doc.title unless doc.title.blank?

    if self.title.blank? && self.titles.any?
      self.title      = self.titles.first
    end
  end


  def process_body(doc)
    self.body         = doc.body unless doc.body.blank?
    self.html_body    = doc.html_body unless doc.body.blank?

    self.description  = doc.description unless doc.description.blank?
    self.lede         = doc.lede unless doc.lede.blank?
  end


  def process_images(doc, force)
    begin
      base_url = doc.url.match(/(http(s)?:\/\/.*?)\//)[0]
      if self.images.empty? || force
        self.cached_images = !doc.images.blank? && doc.images.compact.map{|src| src =~ (/http/) ? src : "#{base_url}#{src}" }
      end
    rescue
      Rails.logger.debug("Failed processing images: #{$!}")
    end
  end



  def process_videos(doc)
    if self.domain
      if self.domain.name =~ /vimeo/
        if extracted_content = Extractula::Vimeo.new(self.url, doc.html).extract
          self.video_embeds   = [extracted_content.video_embed]
          self.video          = Nokogiri::HTML(extracted_content.video_embed).at('iframe')['src']
          self.description = extracted_content.content
        end
      elsif self.domain.name =~ /youtube/
        if extracted_content = Extractula::YouTube.new(self.url, doc.html).extract
          self.video_embeds   = [extracted_content.video_embed]
          self.video          = Nokogiri::HTML(extracted_content.video_embed).at('iframe')['src']
          self.description = extracted_content.content
        end
      end
    else
      videos = doc.videos unless doc.videos.blank?
      self.video ||= videos && videos.first['src']
      self.video_embeds = (videos && videos.map{|v| v.to_s }) || []
    end
  end



  def count_sentences(text)
    m = TactfulTokenizer::Model.new
    result = m.tokenize_text(text)
    result.size
  end



  def process_url(force=false)
    return if last_processed_at && !force

    self.normalize_url!
    self.set_domain!

    doc = self.doc

    self.process_title(doc)

    self.process_body(doc)

    self.process_keywords(doc)

    self.sentence_count = self.count_sentences(self.long_text_for_item)

    if (self.sentence_count.to_i > 4)
      self.process_calais("#{title}\n#{long_text_for_item}")
    end

    self.process_images(doc, force)

    self.process_videos(doc)

    self.favicon = doc.favicon

    self.published_at ||= doc.datetime.acts_like?(:date) ? doc.datetime : nil

    self.tweets_count     = tweets.size if self.tweets

    self.facebook_shares  = self.get_facebook_shares

    # self.classify_for_dashboards

    if self.topics.any?
      Topic.trigger_interest_workers(self.topics, self.id.to_s)
    end

    ImageScraperWorker.perform_async(self.id.to_s)

    self.with(safe: true).save

    self.add_to_dashboards
    #now that the URL has been processed, add it to the dashboards that were cached when it was created
  end

  def doc
    status = Timeout.timeout(5) do
      @doc ||= Pismo::Document.new(self.url, :image_extractor => true, :min_image_width => 200, :min_image_height => 200)
    end
  end

  def process_calais(text)
    begin
      resp = Calais.process_document(
        :content => text,
        :content_type => :html,
        :metadata_enables => Calais::KNOWN_ENABLES,
        :output_format => :json,
        :license_id => 'ruefjhyz87skgb6xpznyakfs'
      )

      tags = JSON.parse(resp.socialtags.to_json)

      self.topics.clear

      tags.select{|h| h['importance'].to_i === 1}.each do |hash|
        name = hash['name']
        self.topics << Topic.find_or_initialize_with_stemming(name)
      end

      self.train_topics
      #so we can learn how to classify things on our own when Calais poops out
    rescue
      Rails.logger.debug("Failed processing metadata from Calais: #{$!}")
      Rails.logger.debug("Processing topics via TopicClassifier")
      self.classify_topics
    end
  end


  def classify_topics
    begin
      if node = TopicClassifier.classify(self.to_bayes)
        t_id = node.to_s.split('t_').last
        if topic = Topic.find(t_id)
          self.topics << topic
        end
      end
    rescue
      Rails.logger.debug("Failed Processing topics via TopicClassifier: #{$!}")
      self.get_topics_from_bitly #last resort
    end
  end


  def get_topics_from_bitly
    #do nothing for now
  end


  def train_topics
    self.topics.each do |topic|
      TopicClassifier.train(topic, self.to_bayes)
    end
  end


  def get_facebook_shares
    begin
      response = MiniFB.get('166820163376988|QGkKj8tmuzEzc-8Tg4-YdNDUGD0', self.url)
      response['shares'].to_i
    rescue
      puts "Error getting FB shares: #{$!}"
    end
  end


  def scrape_images(force=false)
    self.last_processed_at  = Time.now
    begin
      compact_images
      GC.start
      result = []
      self.images.destroy_all
      cached_images.each do |img|
        return img if img.include?(ENV['AWS_ASSETS_BUCKET']) && !force
        self.images.create!(:remote_file_url => img)
      end if cached_images
      save!
    rescue
      Rails.logger.debug("Error scraping images: #{$!}")
    end
  end


end

