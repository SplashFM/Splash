class Comment < ActiveRecord::Base
  NUMBER_OF_COMMENTS_TO_SHOW = 2

  belongs_to :author, :class_name => 'User'
  belongs_to :splash, :counter_cache => true

  validates :body, :presence => true

  def as_json(opts = {})
    {:body       => body,
     :created_at => created_at,
     :author     => author.as_json}
  end
end
