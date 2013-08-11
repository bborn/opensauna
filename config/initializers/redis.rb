if !ENV["REDISCLOUD_URL"].blank?
  uri = URI.parse(ENV["REDISCLOUD_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
  REDIS = Redis.new
end
