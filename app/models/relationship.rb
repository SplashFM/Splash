class Relationship < ActiveRecord::Base
  belongs_to :follower, :class_name => 'User'
  belongs_to :followed, :class_name => 'User'

  validates :followed, :presence => true
  validates :follower, :presence => true
  validates_uniqueness_of :follower_id, :scope => [:followed_id]

  def as_json(opts = {})
    {:type     => 'relationship',
     :follower => follower.as_json,
     :followed => followed.as_json}
  end
end
