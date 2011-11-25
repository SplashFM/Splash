class Event < ActiveRecord::Base
  PER_PAGE = 10

  def self.scope_by(params)
    # TODO: This method is in serious need of cleanup
    last_update_at   = params[:last_update_at]
    main_user_id     = params[:user]
    user_ids         = User.following_ids(params[:follower])
    user_ids << main_user_id unless main_user_id.blank?
    tags             = params[:tags] || []
    page             = params[:page].to_i
    page             = 1 if page < 1
    include_splashes = params[:splashes].present?
    include_mentions = params[:mentions].present? && main_user_id
    include_other    = params[:other].present?

    splashes        = Splash.as_event.for_users(user_ids).since(last_update_at).
      with_tags(tags)
    relationships   = Relationship.as_event.for_users(user_ids).
      since(last_update_at)
    comments        = Comment.as_event.for_users(user_ids).since(last_update_at)

    if main_user_id
      splash_ids      = Splash.ids(main_user_id)
      splash_comments = Comment.as_event.on_splashes(splash_ids).
        since(last_update_at).skip_users(user_ids)

      mentions        = Splash.as_event.since(last_update_at).
        mentioning(main_user_id)
    end

    if params[:count]
      # BUG?: doesn't respect omit_* ?
      splashes.count + relationships.count
    else
      q = ""

      q << splashes.to_sql if include_splashes

      q << " UNION "       if include_mentions && ! q.blank?
      q << mentions.to_sql if include_mentions

      q << " UNION ALL "   if include_splashes && include_other
      if include_other
        q << relationships.to_sql + " UNION ALL " + comments.to_sql

        comment_union = " UNION " << (user_ids.present? ? " ALL " : "")
        if main_user_id && splash_ids.present?
          q << comment_union << splash_comments.to_sql
        end
      end

      q << " ORDER BY created_at DESC"
      q << " LIMIT #{PER_PAGE} OFFSET #{(page - 1) * PER_PAGE}"

      if include_other || include_splashes || include_mentions
        events = Event.find_by_sql(q);
      else
        events = []
      end
      events.map(&:target)
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

  def self.all
    Splash.all
  end

end
