class Comment < ActiveRecord::Base
  include Notification::Target

  NUMBER_OF_COMMENTS_TO_SHOW = 2

  belongs_to :author, :class_name => 'User'
  belongs_to :splash, :counter_cache => true

  validates :body,   :presence => true
  validates :author, :presence => true

  before_create :set_splash_comment

  scope :for_users, lambda { |user_ids|
    user_ids.blank? ? scoped : where(:author_id => user_ids)
  }
  scope :on_splashes, lambda { |splash_ids|
    splash_ids.blank? ? scoped : where(:splash_id => splash_ids)
  }
  scope :since, lambda { |time|
    time.blank? ? scoped : where(['created_at > ?', Time.parse(time).utc])
  }
  scope :skip_users, lambda { |user_ids|
    user_ids.blank? ? scoped : where('author_id not in (?)', user_ids)
  }
  scope :as_event, select("comments.created_at, comments.id target_id, 'Comment' target_type").
                     where(:splash_comment => false)

  def as_json(opts = {})
    {:body       => body,
     :created_at => created_at,
     :type       => 'comment',
     :author     => author.as_json(opts),
     :splash     => splash.active_model_serializer.new(splash, nil, opts)}
  end

  def mentioned_users
    User.nicknamed(*body.scan(/@(#{User::NICKNAME_REGEXP})/))
  end

  private

  def set_splash_comment
    write_attribute(:splash_comment, !! splash_comment)

    nil
  end
end
