module Event
  class Builder
    def build
      splashes
    end

    def count
      @count = true

      self
    end

    def follower(user_id)
      @follower_id = user_id

      self
    end

    def last_update_at(time)
      @last_update_at = Event.from_timestamp(time)

      self
    end

    def tags(tags)
      @tags = tags

      self
    end

    def user(id)
      @user_id = id

      self
    end

    private

    def splashes
      scope = Splash

      if user_ids.present?
        scope = scope.where(:user_id => user_ids)
      end

      if @last_update_at
        scope = scope.where(['created_at > ?', @last_update_at])
      end

      if @tags
        scope = scope.joins(:track => :tags).
          where(:tags => {:name => @tags})
      end

      if @count
        scope.count
      else
        scope.order('created_at desc').all
      end
    end

    def user_ids
      @user_ids ||=
        begin
          user_ids = []

          if @user_id
            user_ids << @user_id
          end

          if @follower_id
            followings = User.
              includes(:following).
              find(@follower_id).
              following.
              map(&:id)

            user_ids.concat followings
          end

          user_ids
        end
    end
  end

  def self.timestamp
    Time.now.utc.iso8601
  end

  def self.from_timestamp(time)
    Time.parse(time).utc
  end

  def self.all
    Splash.all
  end

  def self.scope_builder
    Builder.new
  end
end
