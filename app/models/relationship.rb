class Relationship < ActiveRecord::Base
  belongs_to :follower, :class_name => 'User'
  belongs_to :followed, :class_name => 'User'

  validates :followed, :presence => true
  validates :follower, :presence => true
  validates_uniqueness_of :follower_id, :scope => [:followed_id]

  scope :ignore, lambda { |users| where("followed_id not in (?)", users) }
  scope :ignore_followers, lambda { |users| where("follower_id not in (?)", users) }
  scope :with_followers, lambda { |users| where(:follower_id => users) }
  scope :with_following, lambda { |users| where(:followed_id => users) }
  scope :limited, lambda { |page, count| page(page).per(count) unless page.nil? }

  def as_json(opts = {})
    {:type        => 'relationship',
     :id          => id,
     :follower    => follower.as_json,
     :follower_id => follower_id,
     :followed    => followed.as_json,
     :followed_id => followed_id}
  end

  scope :as_event, select("created_at, id target_id, 'Relationship' target_type")
  scope :for_users, lambda {|user_ids|
    user_ids.blank? ? scoped : where('follower_id in (:user_ids) or followed_id in (:user_ids)',
                                    :user_ids => user_ids)
  }
  scope :since, lambda { |time|
    time.blank? ? scoped : where(['created_at > ?', Time.parse(time).utc])
  }

  def self.followed_ids(follower_id)
    t = arel_table
    s = t.project(:followed_id)
    w = t[:follower_id].eq(follower_id)

    connection.select_values(s.where(w).to_sql)
  end
end
