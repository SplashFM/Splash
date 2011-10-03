require 'testable_search'

class Track < ActiveRecord::Base
  module HasData
    def self.included(target)
      target.has_attached_file :data
    end
  end

  ALLOWED_FILTERS = [:genre, :artist]
  ALLOWED_ATTACHMENT_EXTS = %w(.mp3 .m4a)
  ALLOWED_ATTACHMENTS = ALLOWED_ATTACHMENT_EXTS.
    to_sentence(:two_words_connector => ', ', :last_word_connector => ', ')
  DEFAULT_ALBUM_ART_URL = "no_album_art.png"
  INVALID_ATTACHMENT = "activerecord.errors.messages.invalid_attachment"

  extend TestableSearch

  include HasData

  has_and_belongs_to_many :genres, :join_table => :track_genres
  has_and_belongs_to_many :performers, :join_table => :track_performers,
                                       :class_name => 'Artist'

  validates_presence_of :title

  validate :validate_attachment_type

  # Search for tracks matching the given query.
  #
  # Searches all "string" fields on the Track model.
  #
  # @param [String] query the query used to filter tracks
  #
  # @return a (possibly empty) list of tracks
  def self.with_text(query)
    if use_slow_search?
      # We want to use memory-based sqlite3 for most tests.
      # This is ugly, but tests run faster.
      # Also see User.with_text.
      # WARNING: only works for title search

      fields = content_columns.select { |c| c.type == :string }.map(&:name)
      q      = fields.map { |f| "#{f} = :query" }.join(' or ')

      where([q, {:query => query}])
    else
      FlatTrack.with_text(query)
    end
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

  # FIXME: Remove when the upload form supports multiple performers
  def performer; end

  def performer=(name)
    self.performers = [Artist.find_or_create_by_name(name)]
  end
  # /FIXME

  def performer_names
    performers.map(&:name)
  end

  def downloadable?
    false
  end

  def purchasable?
    false
  end

  private

  def validate_attachment_type
    if data.file?
      unless ALLOWED_ATTACHMENT_EXTS.include?(File.extname(data.path))
        errors.add(:data_content_type,
                   I18n.t(INVALID_ATTACHMENT, :allowed => ALLOWED_ATTACHMENTS))
      end
    end
  end
end

require_dependency 'undiscovered_track'
require_dependency 'discovered_track'

