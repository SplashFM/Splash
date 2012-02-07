Redis::Objects.redis = Redis.new(:host => AppConfig.redis['host'],
                                 :port => AppConfig.redis['port'])
