class Relationship < ActiveRecord::Base
  belongs_to :follower, :class_name => 'User'
  belongs_to :followed, :class_name => 'User'

  validates :followed, :presence => true
  validates :follower, :presence => true
  validates_uniqueness_of :follower_id, :scope => [:followed_id]

  scope :ignore, lambda { |users| where("followed_id not in (?)", users) }
  scope :with_followers, lambda { |users| where(:follower_id => users) }

  def as_json(opts = {})
    {:type     => 'relationship',
     :follower => follower.as_json,
     :followed => followed.as_json}
  end

  scope :as_event, select("created_at, id target_id, 'Relationship' target_type")
  scope :for_users, lambda {|user_ids|
    user_ids.blank? ? scoped : where('follower_id in (:user_ids) or followed_id in (:user_ids)',
                                    :user_ids => user_ids)
  }
  scope :since, lambda { |time|
    time.blank? ? scoped : where(['created_at > ?', Time.parse(time).utc])
  }
end
