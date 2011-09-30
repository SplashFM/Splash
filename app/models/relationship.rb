class Relationship < ActiveRecord::Base
  belongs_to :follower, :class_name => 'User'
  belongs_to :followed, :class_name => 'User'

  validates :followed, :presence => true
  validates :follower, :presence => true
  validates_uniqueness_of :follower_id, :scope => [:followed_id]
end
