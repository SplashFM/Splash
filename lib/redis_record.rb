module RedisRecord
  def self.redis
    @redis ||= Redis.new(:host => AppConfig.redis['host'],
                         :port => AppConfig.redis['port'])
  end

  def self.reset_all
    redis.keys('*').each { |k| redis.del(k) }
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

    def redis_sorted_field(name)
      instance_eval <<-RUBYI
        def sorted_#{name.to_s.pluralize}(page, num_records)
          page  = page.to_i <= 1 ? 1 : page.to_i
          start = (page - 1) * num_records
          stop  = start + num_records - 1

          RedisRecord.redis.zrevrange(key("sorted_#{name}"), start, stop)
        end

        def sorted_by_#{name}(page, num_records)
          ids   = sorted_#{name.to_s.pluralize}(page, num_records).map(&:to_i)
          cache = Hash[*where(:id => ids).map { |t| [t.id, t] }.flatten]

          ids.map { |id| cache[id] }
        end

        def increment_#{name}_sorted(id)
          RedisRecord.redis.zincrby key("sorted_#{name}"), 1, id.to_s
        end

        def reset_#{name}_sorted
          RedisRecord.redis.del key("sorted_#{name}")
        end

        def update_#{name}_score(id, score)
          RedisRecord.redis.zadd key("sorted_#{name}"), score, id
        end

        def update_#{name}_scores(data)
          data.each { |(id, score)| update_#{name}_score(id, score) }
        end
      RUBYI

      class_eval <<-RUBY
        def #{name}_rank
          redis.zrevrank(key("sorted_#{name}"), id.to_s)
        end
      RUBY
    end

    def redis_counter(name)
      redis_sorted_field name

      instance_eval <<-RUBYI
        def increment_#{name.to_s.pluralize}(ids)
          ids.each { |id|
            increment_#{name}(id)
          }
        end

        def increment_#{name}(id)
          RedisRecord.redis.hincrby key(#{name.to_s.inspect}), id.to_s, 1

          increment_#{name}_sorted(id)
        end

        def reset_#{name}_counter
          RedisRecord.redis.del key(#{name.to_s.inspect})
        end

        def reset_#{name.to_s.pluralize}
          reset_#{name}_counter
          reset_#{name}_sorted
        end

        def update_#{name}(id, count)
          RedisRecord.redis.hset key(#{name.to_s.inspect}), id.to_s, count

          update_#{name}_score(id, count)
        end

        def #{name.to_s.pluralize}(ids = [])
          if ids.empty?
            RedisRecord.redis.hgetall(key(#{name.to_s.inspect}))
          else
            RedisRecord.redis.hmget(key(#{name.to_s.inspect}), *ids)
          end
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

    # Example: redis_hash :splashed_tracks
    # produces:
    #   MyClass#record_splashed_track(track_id)
    #   MyClass#splashed_tracks
    #   MyClass#summed_splashed_tracks
    #   MyClass#replace_summed_splashed_tracks(other_ids)
    # TODO:
    #   MyClass#update_summed_splashed_tracks(other_id, weight)
    #     -1 to subtract; 1 to add
    def redis_hash(name)
      name.to_s.singularize
      instance_eval <<-RUBY
        def reset_#{name.to_s.pluralize}
          keys  = RedisRecord.redis.keys(key("#{name}") + "/*")
          skeys = RedisRecord.redis.keys(key("summed_#{name}") + "/*")

          RedisRecord.redis.del(*keys)  unless keys.blank?
          RedisRecord.redis.del(*skeys) unless skeys.blank?
        end
      RUBY

      class_eval <<-RUBYI
        def record_#{name.to_s.singularize}(track_id)
          k = key("#{name.to_s}/") + id.to_s
          RedisRecord.redis.zadd(k, 1, track_id)
        end

        def #{name}
          k = key("#{name.to_s}/") + id.to_s
          RedisRecord.redis.zrevrange(k, 0, -1)
        end

        def summed_#{name}(page=1, num_records=20)
          page  = page.to_i <= 1 ? 1 : page.to_i
          start = (page - 1) * num_records
          stop  = start + num_records - 1

          k = key("summed_#{name.to_s}/") + id.to_s
          RedisRecord.redis.zrevrange(k, start, stop)
        end

        def replace_summed_#{name}(other_ids)
          return if other_ids.empty?
          k = key("summed_#{name.to_s}/") + id.to_s
          other_keys = other_ids.map {|i| key("#{name.to_s}/") + i.to_s}
          RedisRecord.redis.zunionstore(k, other_keys)
        end
      RUBYI
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
