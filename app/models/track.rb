require 'testable_search'

class Track < ActiveRecord::Base
  ALLOWED_FILTERS = [:genre, :artist]
  DEFAULT_ALBUM_ART_URL = "no_album_art.png"

  extend TestableSearch

  has_and_belongs_to_many :albums, :join_table => :album_tracks
  has_and_belongs_to_many :genres, :join_table => :track_genres
  has_and_belongs_to_many :performers, :join_table => :track_performers,
                                       :class_name => 'Artist'

  validates_presence_of :title

  validate :validate_performer_presence
  validate :validate_track_uniqueness

  # Search for tracks matching the given query.
  #
  # Searches all "string" fields on the Track model.
  #
  # @param [String] query the query used to filter tracks
  #
  # @return a (possibly empty) list of tracks
  def self.with_text(query)
    where([
      "to_tsvector('english', title) @@
         to_tsquery('english', :query)",
       {:query => query.gsub(/\s+/, ' & ')}
    ])
  end

  # Narrow a Relation to include Track's filters
  def self.narrow(r, filters)
    ro = r

    unless (filters.symbolize_keys.keys - ALLOWED_FILTERS).empty?
      raise "Unknown filters: #{filters.inspect}"
    end

    if filters[:genre]
      ro = ro.joins(:track => :genres).
        where(:genres => {:id => filters[:genre]})
    end

    if filters[:artist]
      ro = ro.joins(:track => :performers).
        where(:artists => {:id => filters[:artist]})
    end

    ro
  end

  def album_art_url
    read_attribute(:album_art_url) || DEFAULT_ALBUM_ART_URL
  end

  # FIXME: Remove when the upload form supports multiple albums, performers
  def album; end

  def album=(name)
    self.albums = [Album.find_or_create_by_name(name)] unless name.blank?
  end

  def performer; end

  def performer=(name)
    self.performers = [Artist.find_or_create_by_name(name)] unless name.blank?
  end
  # /FIXME

  def performer_names
    performers.map(&:name)
  end

  def search_result_type
    :track
  end

  def taken?
    ! performers.length.zero? && new_record? && canonical_version
  end

  def downloadable?
    false
  end

  def purchasable?
    false
  end

  def canonical_version
    if new_record?
      Track.
        joins(:performers).
        where(:title => title, :artists => {:id => performer_ids}).first
    else
      self
    end
  end

  private

  def validate_performer_presence
    if performers.length.zero?
      errors.add(:performer,
                 I18n.t('activerecord.errors.messages.invalid'))
    end
  end

  def validate_track_uniqueness
    errors.add(:base, I18n.t('activerecord.errors.messages.taken')) if taken?
  end
end

require_dependency 'undiscovered_track'
require_dependency 'discovered_track'

