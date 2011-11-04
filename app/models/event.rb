class Event < ActiveRecord::Base
  class Builder
    def build
      if @count
        splashes.count + user_followed.count
      else
        q      =
          splashes.to_sql <<
          " UNION ALL " <<
          user_followed.to_sql <<
          " ORDER BY created_at DESC"

        events = Event.find_by_sql(q);

        events.map(&:target)
      end
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

    def user_followed
      scope = User.find(@user_id).
        reverse_relationships.
        select("created_at, id target_id, 'Relationship' target_type")

      if @last_update_at
        scope = scope.where(['created_at > ?', @last_update_at])
      end

      scope
    end

    def splashes
      scope = Splash.select("splashes.created_at,
                             splashes.id target_id,
                             'Splash' target_type")

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

      scope
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

  def self.columns
    @columns ||= []
  end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  column :target_type, :string
  column :target_id, :integer
  column :created_at, :datetime

  belongs_to :target, :polymorphic => true

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
