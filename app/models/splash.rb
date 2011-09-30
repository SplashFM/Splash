class Splash < ActiveRecord::Base
  belongs_to :track
  belongs_to :user

  validates :track_id, :presence => true, :uniqueness => {:scope => :user_id}
  validates :user_id,  :presence => true

  # Return all Splashes made by the given user. Narrow to a single Splash if
  #   track is passed in.
  #
  # @param user the owner of the Splashes
  # @param track the (possibly) splashed track
  #
  # @return A (possibly empty) list of splashes if only the user is passed in.
  #   Otherwise, a single Splash, or nil, if no splash is found for the given
  #   user and track.
  def self.for(user, track = nil)
    r = where(:user_id => user.id)

    track ? r.where(:track_id => track.id).first : r
  end

  def self.for?(user, track)
    exists?(:track_id => track.id, :user_id => user.id)
  end
end
