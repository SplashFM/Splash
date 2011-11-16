class Comment < ActiveRecord::Base
  NUMBER_OF_COMMENTS_TO_SHOW = 2

  belongs_to :author, :class_name => 'User'
  belongs_to :splash, :counter_cache => true

  validates :body, :presence => true

  scope :for_users, lambda { |user_ids|
    user_ids.blank? ? scoped : where(:author_id => user_ids)
  }
  scope :since, lambda { |time|
    time.blank? ? scoped : where(['created_at > ?', Time.parse(time).utc])
  }
  scope :as_event, select("comments.created_at, comments.id target_id, 'Comment' target_type").
                     where(:skip_feed => false)

  def as_json(opts = {})
    {:body       => body,
     :created_at => created_at,
     :type       => 'comment',
     :author     => author.as_json,
     :splash     => splash.as_json}
  end
end
