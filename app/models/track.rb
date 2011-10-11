require 'testable_search'

class Track < ActiveRecord::Base
  ALLOWED_FILTERS = [:genre, :artist]
  DEFAULT_ALBUM_ART_URL = "no_album_art.png"

  extend TestableSearch

  has_and_belongs_to_many :genres, :join_table => :track_genres

  validates_presence_of :title

  validate :validate_performer_presence
  validate :validate_track_uniqueness

  def self.string_list_to_array(str)
    if str.present?
      str.split(/\s*;;\s*/)
    else
      []
    end
  end

  def self.value_to_string_list(value)
    l = case value
        when Array
          value
        when String
          string_list_to_array(value)
        else
          raise "Don't know how to handle #{value.inspect}"
        end

    l.sort.map(&:strip).join(" ;; ")
  end

  # Search for tracks matching the given query.
  #
  # Searches all "string" fields on the Track model.
  #
  # @param [String] query the query used to filter tracks
  #
  # @return a (possibly empty) list of tracks
  def self.with_text(query)
    where([
      "to_tsvector('english',
                   coalesce(title, '') || ' ' ||
                   coalesce(performers, '') || ' ' ||
                   coalesce(albums, '')) @@
         plainto_tsquery('english', ?)",
       query
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
      # TODO this will probably be faster using a full text search
      ro = ro.joins(:track).
        where(['tracks.performers ilike ?',
               value_to_string_list(filters[:artist])])
    end

    ro
  end

  def album_art_url
    read_attribute(:album_art_url) || DEFAULT_ALBUM_ART_URL
  end

  def albums
    Track.string_list_to_array(read_attribute(:albums))
  end

  def albums=(value)
    write_attribute(:albums, Track.value_to_string_list(value))
  end

  def performers
    Track.string_list_to_array(performers_string)
  end

  alias_method :performer_names, :performers

  def performers_string
    read_attribute(:performers)
  end

  def performers=(value)
    write_attribute(:performers, Track.value_to_string_list(value))
  end

  def search_result_type
    :track
  end

  def taken?
    performers.present? && new_record? && canonical_version
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
        where(:title => title, :performers => performers_string).first
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

