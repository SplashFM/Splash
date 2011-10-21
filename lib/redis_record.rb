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
          ids.each { |id|
            increment_#{name}(id)
            increment_#{name}_sorted(id)
          }
        end

        def increment_#{name}(id)
          RedisRecord.redis.hincrby key(#{name.to_s.inspect}), id.to_s, 1
        end

        def increment_#{name}_sorted(id)
          RedisRecord.redis.zincrby key("sorted_#{name}"), 1, id.to_s
        end

        def reset_#{name.to_s.pluralize}
          RedisRecord.redis.del key(#{name.to_s.inspect})
          RedisRecord.redis.del key("sorted_#{name}")
        end

        def sorted_#{name.to_s.pluralize}(page, num_records)
          page  = page.to_i <= 1 ? 1 : page
          start = (page - 1) * num_records
          stop  = start + num_records

          RedisRecord.redis.zrevrange(key("sorted_#{name}"), start, stop)
        end

        def sorted_by_#{name}(page, num_records)
          ids   = sorted_#{name.to_s.pluralize}(page, num_records).map(&:to_i)
          cache = Hash[*where(:id => ids).map { |t| [t.id, t] }.flatten]

          ids.map { |id| cache[id] }
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
