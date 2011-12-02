require 'paperclip_processors/metadata'

class UndiscoveredTrack < Track
  ALLOWED_ATTACHMENT_EXTS = %w(mp3 m4a)
  ALLOWED_ATTACHMENTS = ALLOWED_ATTACHMENT_EXTS.
    to_sentence(:two_words_connector => ', ', :last_word_connector => ', ')
  INVALID_ATTACHMENT = "activerecord.errors.messages.invalid_attachment"

  ATTACHMENT_OPTS = {
    :hash_secret => ":class/:attachment/:id",
    # processors are only used when you have a style specification
    :processors  => [:metadata],
    :styles      => {:original => [:metadata]},
  }

  ARTWORK_OPTS = {
    :default_style => :normal,
    :styles        => {:normal => '100x100>'},
    :default_url   => DEFAULT_ARTWORK_URL,
    :hash_secret   => ":class/:attachment/:id"
  }

  if AppConfig.aws && ! Rails.env.test?
    has_attached_file :data,
      {:path   => "/:class/:attachment/:id/:hash.:extension",
       :storage => :s3,
       :s3_credentials => {
         :access_key_id => AppConfig.aws['access_key_id'],
         :secret_access_key => AppConfig.aws['secret_access_key'],
         :bucket => AppConfig.aws['bucket']
        },
       :s3_headers => {"Content-Disposition" => "attachment"},
     }.merge!(ATTACHMENT_OPTS)

    has_attached_file :artwork, {
      :path    => "/:class/:attachment/:id/:hash",
      :storage => :s3,
      :s3_credentials => {
        :access_key_id => AppConfig.aws['access_key_id'],
        :secret_access_key => AppConfig.aws['secret_access_key'],
        :bucket => AppConfig.aws['bucket']
      },
    }.merge!(ARTWORK_OPTS)
  else
    has_attached_file :data,
      {:path => "#{Rails.root}/tmp/:class/:attachment/:id/:hash.:extension"}.
        merge!(ATTACHMENT_OPTS)

    has_attached_file :artwork, {
      :path => "#{Rails.root}/tmp/:class/:attachment/:id/:hash.:extension",
    }.merge!(ARTWORK_OPTS)
  end

  belongs_to :uploader, :class_name => 'User'

  validate :validate_attachment_type

  validates_presence_of :title,          :if => :full_validation?
  validate :validate_performer_presence, :if => :full_validation?
  validate :validate_track_uniqueness,   :if => :full_validation?

  def artwork_url
    artwork.url
  end

  def as_json(opts = {})
    super(opts).
      merge!(:download_url => download_url)
  end

  def preview_type
    File.extname(data_file_name).split('.').last
  end

  def preview_url
    data.url
  end

  alias_method :download_url, :preview_url
  alias_method :preview_url?, :preview_url

  def downloadable?
    data.file?
  end

  def replace_with_canonical
    destroy and return canonical_version
  end

  private

  def full_validation?
    ! new_record? || title.present? || performers.present?
  end

  def validate_attachment_type
    if data.file?
      unless ALLOWED_ATTACHMENT_EXTS.include?(preview_type)
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
