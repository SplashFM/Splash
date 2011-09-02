class Track < ActiveRecord::Base
  validates_presence_of :title, :artist

  MAX_RESULTS = 3

  # Search for tracks matching the given query.
  #
  # Searches all "string" fields on the Track model.
  #
  # @param [String] query the query used to filter tracks
  #
  # @return a (possibly empty) list of tracks
  def self.filtered(query)
    search(query)
  end
end
