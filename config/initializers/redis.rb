redis = Redis.new(:host => AppConfig.redis['host'],
                  :port => AppConfig.redis['port'])
Redis::Objects.redis = redis
Redis.current = redis
