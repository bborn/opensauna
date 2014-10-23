uri_string = ENV['REDIS_URL'] || ENV['REDISTOGO_URL'] || ENV['REDISCLOUD_URL']
if uri_string
  uri = URI.parse(uri_string)
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
  REDIS = Redis.new
end
