class Event < ActiveRecord::Base
  PER_PAGE = 10

  def self.scope_by(params)
    last_update_at = params[:last_update_at]
    user_ids       = User.following_ids(params[:follower])
    user_ids << params[:user] unless params[:user].blank?
    tags           = params[:tags] || []
    page           = params[:page].to_i
    page           = 1 if page < 1
    omit_splashes  = params[:omit_splashes] == 'true'
    omit_other     = params[:omit_other] == 'true'

    splashes      = Splash.as_event.for_users(user_ids).since(last_update_at).
      with_tags(tags)
    relationships = Relationship.as_event.for_users(user_ids).
      since(last_update_at)
    comments      = Comment.as_event.for_users(user_ids).since(last_update_at)

    if params[:count]
      # BUG?: doesn't respect omit_* ?
      splashes.count + relationships.count
    else
      q = ""

      q << splashes.to_sql unless omit_splashes
      q << " UNION ALL " unless omit_other || omit_splashes
      q << relationships.to_sql + " UNION ALL " + comments.to_sql unless omit_other
      q << " ORDER BY created_at DESC"
      q << " LIMIT #{PER_PAGE} OFFSET #{(page - 1) * PER_PAGE}"

      events = Event.find_by_sql(q);

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
