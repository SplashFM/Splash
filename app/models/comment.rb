class Comment < ActiveRecord::Base
  NUMBER_OF_COMMENTS_TO_SHOW = 2

  belongs_to :author, :class_name => 'User'
  belongs_to :splash, :counter_cache => true

  validates :body, :presence => true

  def as_json(opts = {})
    super(:methods => :author_name)
  end

  def author_name
    author.name
  end
end
