class UndiscoveredTrack < Track
  ALLOWED_ATTACHMENT_EXTS = %w(.mp3 .m4a)
  ALLOWED_ATTACHMENTS = ALLOWED_ATTACHMENT_EXTS.
    to_sentence(:two_words_connector => ', ', :last_word_connector => ', ')
  INVALID_ATTACHMENT = "activerecord.errors.messages.invalid_attachment"

  has_attached_file :data

  validate :validate_attachment_type

  validates_presence_of :title,          :if => :full_validation?
  validate :validate_performer_presence, :if => :full_validation?
  validate :validate_track_uniqueness,   :if => :full_validation?

  def preview_type
    File.extname(data.path).split('.').last
  end

  def preview_url
    data.url
  end

  alias_method :preview_url?, :preview_url

  def download_path
    data.path
  end

  def downloadable?
    data.file?
  end

  def fill_metadata
    self.title      = song_file.title
    self.albums     = song_file.album
    self.performers = song_file.artist

    self
  end

  def replace_with_canonical
    destroy and return canonical_version
  end

  def song_file
    @song_file ||= SongFile.new(data.path)
  end

  private

  def full_validation?
    ! new_record? || title.present? || performers.present?
  end

  def validate_attachment_type
    if data.file?
      unless ALLOWED_ATTACHMENT_EXTS.include?(File.extname(data.path))
        errors.add(:data_content_type,
                   I18n.t(INVALID_ATTACHMENT, :allowed => ALLOWED_ATTACHMENTS))
      end
    end
  end

  def validate_performer_presence
    if performers.length.zero?
      errors.add(:performers,
                 I18n.t('activerecord.errors.messages.invalid'))
    end
  end

  def validate_track_uniqueness
    errors.add(:base, I18n.t('activerecord.errors.messages.taken')) if taken?
  end
end
