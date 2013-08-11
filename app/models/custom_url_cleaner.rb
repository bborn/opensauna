class CustomUrlCleaner
  attr_accessor :url


  def initialize(url)
    self.url = url
  end

  def clean_up
    instagram_cleaner

    url
  end


  def instagram_cleaner
    if url.url.match(/instagram|instagr\.am/)
      replace_summary("is using Instagram", "Instagram photo")
    end

    url
  end

  def replace_summary(test, replacement)
    ['body', 'lede', 'description'].each do |attribute|
      url.send("#{attribute}=", replacement) if !url.send("#{attribute}").blank? && url.send("#{attribute}").include?(test)
    end
  end

end
