require 'song_file'

class UndiscoveredTrack < Track
  ALLOWED_ATTACHMENT_EXTS = %w(mp3 m4a)
  ALLOWED_ATTACHMENTS = ALLOWED_ATTACHMENT_EXTS.
    to_sentence(:two_words_connector => ', ', :last_word_connector => ', ')
  INVALID_ATTACHMENT = "activerecord.errors.messages.invalid_attachment"

  DEFAULT_ART_SIZE = 71

  PREFIX = Rails.env.development? || Rails.env.test? ? "#{Rails.root}/tmp" : ""

  ATTACHMENT_OPTS = {
    :hash_secret => ":class/:attachment/:id",
    :path        => "#{PREFIX}/:class/:attachment/:id/:hash.:extension"
  }

  ARTWORK_OPTS = {
    :default_style => :normal,
    :styles        => {:normal => '#{DEFAULT_ART_SIZE}x#{DEFAULT_ART_SIZE}>'},
    :default_url   => DEFAULT_ARTWORK_URL,
    :hash_data     => ":class/:attachment/:id/:style/:filename",
    :hash_secret   => ":class/:attachment/:id",
    :path          => "#{PREFIX}/:class/:attachment/:id/:hash"
  }

  S3_OPTS = {
    :storage        => :s3,
    :s3_credentials => {
      :access_key_id     => AppConfig.aws['access_key_id'],
      :secret_access_key => AppConfig.aws['secret_access_key'],
      :bucket            => AppConfig.aws['bucket']
    },
  }

  has_attached_file :local_data,
    :path => "#{PREFIX}/mnt/uploads/:class/:attachment/:id/:filename"

  if AppConfig.aws && ! Rails.env.test?
    has_attached_file :data,
      S3_OPTS.
        merge(ATTACHMENT_OPTS).
        merge(:s3_headers => {"Content-Disposition" => "attachment"})
    has_attached_file :artwork, S3_OPTS.merge(ARTWORK_OPTS)
  else
    has_attached_file :data,    ATTACHMENT_OPTS
    has_attached_file :artwork, ARTWORK_OPTS
  end

  before_destroy :prepare_clear_redis

  has_many :splashes, :foreign_key => :track_id, :dependent => :destroy

  belongs_to :uploader, :class_name => 'User'

  validate :validate_local_data_type,    :if => :local_data?
  validate :validate_data_type,          :if => :data?

  validates_presence_of :title,          :on => :update
  validate :validate_performer_presence, :on => :update
  validate :validate_track_uniqueness,   :on => :update

  before_create :extract_artwork
  after_create  :extract_metadata
  before_create :set_default_popularity_rank
  before_update :publish, :if => :local_data?
  after_destroy  :clear_redis

  def artwork_url
    artwork.url
  end

  def preview_type(name = data_file_name)
    name and File.extname(name).split('.').last
  end

  def preview_url
    data.url
  end

  alias_method :download_url, :preview_url
  alias_method :preview_url?, :preview_url

  def downloadable?
    data.file?
  end

  def publish
    f = local_data.to_file(:original)

    self.data       = f
    self.local_data = nil

    set_data_content_disposition(data,
                                 display_file_name(title, File.extname(f.path)))
  end

  def replace_with_canonical
    destroy and return canonical_version
  end

  private

  def local_song_file
    @song_file ||= SongFile.new(local_data.to_file(:original).path)
  end

  def create_identicon(title, artist)
    t, a = title, artist
    hash = Digest::MD5.hexdigest(t.to_s + a.to_s + Time.now.to_s)
    idtc = Quilt::Identicon.new hash, size: DEFAULT_ART_SIZE * 2

    tf = Paperclip::Tempfile.new([hash, 'png'])

    begin
      idtc.write tf

      self.artwork = tf
    ensure
      tf.close true if tf
    end
  end

  def data_content_disposition(filename)
    {"Content-Disposition" => "attachment; filename=#{filename.inspect}"}
  end

  def extract_artwork
    if (artwork = local_song_file.artwork)
      self.artwork = artwork
    else
      create_identicon local_song_file.title, local_song_file.artist
    end
  end

  def extract_metadata
    self.title      = local_song_file.title
    self.albums     = local_song_file.album
    self.performers = local_song_file.artist
  end

  def display_file_name(title, ext)
    title.gsub(/\W+/, ' ').squeeze(' ').strip + '.' + ext.sub(/^\./, '')
  end

  def set_data_content_disposition(data, filename)
    data.instance_variable_set :@s3_headers, data_content_disposition(filename)
  end

  def set_default_popularity_rank
    self.popularity_rank ||= Track::UNDISCOVERED_POPULARITY
  end

  def validate_data_type
    validate_type data_file_name
  end

  def validate_local_data_type
    validate_type local_data_file_name
  end

  def validate_type(name)
    unless ALLOWED_ATTACHMENT_EXTS.include?(preview_type(name))
      errors.add(:data_content_type,
                 I18n.t(INVALID_ATTACHMENT, :allowed => ALLOWED_ATTACHMENTS))
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
