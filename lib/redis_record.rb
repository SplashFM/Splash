module RedisRecord
  def self.redis
    @redis ||= Redis.new(:host => AppConfig.redis['host'],
                         :port => AppConfig.redis['port'])
  end

  module ClassMethods
    def key(field)
      "#{Rails.env}/#{redis_base_key}/#{field}"
    end

    def redis_base_key(key = nil)
      if key
        write_inheritable_attribute(:base_key, key)
      else
        read_inheritable_attribute(:base_key) || name.underscore
      end
    end

    def redis_counter(name)
      instance_eval <<-RUBYI
        def increment_#{name.to_s.pluralize}(ids)
          ids.each { |id| increment_#{name}(id) }
        end

        def increment_#{name}(id)
          RedisRecord.redis.hincrby key(#{name.to_s.inspect}), id.to_s, 1
        end

        def reset_#{name.to_s.pluralize}
          RedisRecord.redis.del key(#{name.to_s.inspect})
        end

        def #{name.to_s.pluralize}
          RedisRecord.redis.hgetall(key(#{name.to_s.inspect}))
        end
      RUBYI

      class_eval <<-RUBY
        def increment_#{name}
          self.class.increment_#{name.to_s.pluralize}([id])
        end

        def #{name}
          RedisRecord.redis.hget(key(#{name.to_s.inspect}), id.to_s).to_i
        end
      RUBY
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end

  def key(base)
    self.class.key(base)
  end

  def redis
    RedisRecord.redis
  end
end
