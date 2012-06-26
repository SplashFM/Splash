require 'redis_record'

class Track < ActiveRecord::Base
  paginates_per 5

  # FIXME: wrong! wrong! wrong!
  DEFAULT_ARTWORK_URL     = "http://splash.fm/images/no_album_art.png"
  # what popularity value to use for UndiscoveredTracks
  UNDISCOVERED_POPULARITY = -1

  include RedisRecord
  include Track::Stats

  acts_as_taggable

  has_many :splashes

  scope :splashed, joins(:splashes)
  scope :popular, where("popularity_rank < 1000")

  attr_accessor :scoped_splash_count

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

  # Search for tracks matching the given query.
  #
  # Searches all "string" fields on the Track model.
  #
  # @param [String] query the query used to filter tracks
  #
  # @return a (possibly empty) list of tracks
  def self.with_text(query, popular = false)
    cfg = 'english'

    tsv = <<-SQL
      (setweight(to_tsvector('#{cfg}', coalesce(title, '')), 'A') ||
       setweight(to_tsvector('#{cfg}', coalesce(performers, '')), 'B'))
    SQL
    tsq = Track.send(:sanitize_sql, ["plainto_tsquery('#{cfg}', ?)", query])

    # order of weights: D, C, B, A - meaning: (nothing), performers, title
    weights = '{0.0, 0.1, 0.9, 1}'

    # 8 divides the rank by the number of unique words in document
    # 32 divides the rank by itself + 1
    normalization = "8|32"

    # the ts_rank values vary from 0 to 1
    # popularity_rank values vary from 1 to 1000

    # how much to weight popularity relative to FTS rank
    popularity_weight = 0.25

    pop_rank = "#{popularity_weight}*(1 - popularity_rank / 1000)"
    ts_rank = "ts_rank('#{weights}', #{tsv}, #{tsq}, #{normalization})"

    rank = "(#{ts_rank} + #{pop_rank}) as rank"

    q = select("*, #{rank}")
    q = q.where('popularity_rank < 1000') if popular

    q.where("#{tsv} @@ #{tsq}").order('rank DESC')
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
                    title.downcase, performers_string.downcase]).order("created_at").first
    else
      nil
    end
  end
end

require_dependency 'undiscovered_track'
require_dependency 'discovered_track'
