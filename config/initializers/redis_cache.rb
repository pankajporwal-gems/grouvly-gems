# if ENV['REDIS_URL'].present?
#   radis = Redis.new(url: ENV['REDIS_URL'])
#   db = ENV["REDIS_USER_CACHE_DB"].presence || 1
#   $redis_user_cache = Redis.new(:host => radis.client.options[:host], :port => radis.client.options[:port], :db => db)
# else
#   raise "Missing REDIS_URL!"
# end