Twitter.configure do |twitter_config|
  twitter_config.consumer_key = ENV['TWITTER_CONSUEMER_KEY']
  twitter_config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
  twitter_config.oauth_token = ENV['TWITTER_OAUTH_TOKEN']
  twitter_config.oauth_token_secret = ENV['TWITTER_OAUTH_SECRET']
  twitter_config.endpoint = 'http://api.twitter.com/1'
end
