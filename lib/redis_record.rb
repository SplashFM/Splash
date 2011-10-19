module RedisRecord
  module ClassMethods
    def redis
      @redis ||= Redis.new(:host => AppConfig.redis['host'],
                       :port => AppConfig.redis['port'])
    end

    def key(field)
      "#{Rails.env}/#{name.underscore}/#{field}"
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end

  def key(base)
    self.class.key(base)
  end

  def redis
    self.class.redis
  end
end
