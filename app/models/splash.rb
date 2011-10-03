class Splash < ActiveRecord::Base
  belongs_to :track
  belongs_to :user

  validates :track_id, :presence => true, :uniqueness => {:scope => :user_id}
  validates :user_id,  :presence => true

  # Return the Splashes for a given user.
  #
  # @param user the owner of the Splashes
  # @param filters a Hash of filters or a (possibly splashed) track
  #
  # @return A (possibly empty) list of splashes, if only the user is passed in
  #   or the second argument is a Hash. Otherwise return a single Splash, or
  #   nil if no splash is found for the given user and track.
  def self.for(user, filters = nil)
    r = where(:user_id => user.id)

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
end
