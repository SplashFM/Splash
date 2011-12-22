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

  scope :splashed, where('id in (select s.track_id from splashes s)')

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
        when nil
          []
        else
          raise "Don't know how to handle #{value.inspect}"
        end

    l.sort.map(&:strip).join(" ;; ")
  end

  def self.recompute_splash_counts
    Track.reset_splash_counts

    splashed.find_each(:batch_size => 100) { |t| t.recompute_splash_count }
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
    return with_weighted_text(query)
    where(["to_tsvector('english',
                        coalesce(title, '') || ' ' ||
                        coalesce(performers, '') || ' ' ||
                        coalesce(albums, '')) @@
              plainto_tsquery('english', ?)",
       query
    ]).order(:popularity_rank)
  end

  def self.with_weighted_text(query)
   tsv = <<-SQL
      (setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
       setweight(to_tsvector('english', coalesce(performers, '')), 'B') ||
       setweight(to_tsvector('english', coalesce(albums, '')), 'C')
      )
    SQL
    tsq = Track.send(:sanitize_sql, ["plainto_tsquery('english', ?)", query])

    # order of weights: D, C, B, A - meaning: (nothing), albums, performers, title
    weights = '{0.0, 0.1, 0.3, 1}'

    # 8 divides the rank by the number of unique words in document
    # 32 divides the rank by itself + 1
    normalization = "8|32"

    # the ts_rank values vary from 0 to 1
    # popularity_rank values vary from 1 to 1000

    # what popularity value to use for UndiscoveredTracks
    undiscovered_popularity = 1

    # how much to weight popularity relative to FTS rank
    popularity_weight = 0.25

    pop_rank = "#{popularity_weight}*(1 - coalesce(popularity_rank, #{undiscovered_popularity}) / 1000)"
    ts_rank = "ts_rank('#{weights}', #{tsv}, #{tsq}, #{normalization})"

    rank = "(#{ts_rank} + #{pop_rank}) as rank"

    # prefer exact matching, but only in title or performers
    exact = Track.send(:sanitize_sql, ["(title || performers) ilike ? as exact", "%#{query}%"])
    select("*, #{rank}, #{exact}").where("#{tsv} @@ #{tsq}").order("exact DESC, rank DESC")
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

  def preview_type; end

  def preview_url; end

  def recompute_splash_count
    self.class.update_splash_count(id, Splash.for_tracks(self).count)
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

