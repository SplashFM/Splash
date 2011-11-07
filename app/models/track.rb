require 'redis_record'
require 'testable_search'

class Track < ActiveRecord::Base
  paginates_per 5

  DEFAULT_ARTWORK_URL = "/images/no_album_art.png"

  include RedisRecord
  extend TestableSearch

  redis_base_key :track
  redis_counter :splash_count

  acts_as_taggable

  has_and_belongs_to_many :genres, :join_table => :track_genres

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

  def self.top_splashed(page, num_records)
    sorted_by_splash_count(page, num_records)
  end

  # Search for tracks matching the given query.
  #
  # Searches all "string" fields on the Track model.
  #
  # @param [String] query the query used to filter tracks
  #
  # @return a (possibly empty) list of tracks
  def self.with_text(query)
    where(["to_tsvector('english',
                        coalesce(title, '') || ' ' ||
                        coalesce(performers, '') || ' ' ||
                        coalesce(albums, '')) @@
              plainto_tsquery('english', ?)",
       query
    ]).order(:popularity_rank)
  end

  def as_json(options = {})
    {:id          => id,
     :title       => title,
     :artwork_url => artwork_url,
     :performers  => performers.to_sentence}
  end

  def artwork_url
    read_attribute(:artwork_url) || DEFAULT_ARTWORK_URL
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
    canonical_version.present? && canonical_version != self
  end

  def downloadable?
    false
  end

  def purchasable?
    false
  end

  def canonical_version
    if title.present? && performers.present?
      @canonical_version ||=
        Track.where(['lower(title) = ? AND lower(performers) = ?',
                    title.downcase, performers_string.downcase]).first
    else
      nil
    end
  end
end

require_dependency 'undiscovered_track'
require_dependency 'discovered_track'

