class Splash < ActiveRecord::Base
  belongs_to :track
  belongs_to :user
  belongs_to :parent, :class_name => 'Splash'

  validates :user_id,  :presence => true
  validates :track_id, :presence => true, :uniqueness => {:scope => :user_id}

  before_create :freeze_hierarchies, :if => :resplash?

  # Return the Splashes for a given user.
  #
  # @param user the owner or owners of the Splashes
  # @param filters a Hash of filters or a (possibly splashed) track
  #
  # @return A (possibly empty) list of splashes, if only the user is passed in
  #   or the second argument is a Hash. Otherwise return a single Splash, or
  #   nil if no splash is found for the given user and track.
  def self.for(users, filters = nil)
    users = users.respond_to?(:each) ? users : [users]

    r = where(:user_id => users.map(&:id))

    case filters
    when Track
      r.where(:track_id => track.id).first
    when Hash
      r = Track.narrow(r, filters)
    when nil
      r
    else
      raise "Unknown filters: #{filters}"
    end
  end

  def self.for?(user, track)
    exists?(:track_id => track.id, :user_id => user.id)
  end

  def self.since(time)
    where(['created_at > ?', Time.parse(time).utc])
  end

  def owned_by?(user)
    self.user == user
  end

  def resplash?
    parent_id? || parent.present?
  end

  def user_path
    (user_list || '').split(',')
  end

  def user_path=(user_ids)
    self.user_list = user_ids.join(',')
  end

  private

  def freeze_hierarchies
    self.user_path = parent.user_path + [parent.user.id]
  end
end
