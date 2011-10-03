require 'texticle/searchable'

class FlatTrack < ActiveRecord::Base
  extend Searchable(:title, :album, :performers)

  include Track::HasData

  def self.with_text(query)
    search(query)
  end

  def performer_names
    performers.split('|')
  end

  def search_result_type
    :track
  end
end
