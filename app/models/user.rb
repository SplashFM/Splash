require 'redis_record'
require 'open-uri'
require 'cropper'

class User < ActiveRecord::Base
  include RedisRecord
  include Redis::Objects
  include User::Stats

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  ACCESS_CODES_PATH = File.join(Rails.root, %w(config access_codes.yml))

  NICKNAME_REGEXP = '\w[A-Za-z\d_.-]+\w'

  DEFAULT_AVATAR_URL = '/images/dummy_user_:style.png'
  AVATAR_WIDTH = 125
  AVATAR_HEIGHT = 185
  SUGGESTED_USERS_PER_PAGE = 3
  DEFAULT_EMAIL_PREFERENCES = { 'following' => 'true',
                                'mention'   => 'true',
                                'splash_comment' => '',
                                'response_comment' => '',
                                'newsletter' => 'true' }

  serialize :ignore_suggested_users, Array
  serialize :suggested_users, Array
  serialize :email_preferences, Hash
  serialize :settings, Hash

  attr_accessor :access_code
  attr_accessor :delete_avatar, :crop_x, :crop_y, :crop_w, :crop_h

  has_many :relationships, :foreign_key => 'follower_id'
  # The users I am following.
  has_many :following, :through => :relationships, :source => :followed

  has_many :reverse_relationships, :foreign_key => 'followed_id',
                                   :class_name => 'Relationship'

  # The users who are following me.
  has_many :followers, :through => :reverse_relationships
  has_many :uploaded_tracks,
           :class_name  => 'UndiscoveredTrack',
           :foreign_key => 'uploader_id'

  has_many :comments, :foreign_key => :author_id
  has_many :social_connections,
           :after_add => [Suggestions.new, SocialAvatar.new]

  ATTACHMENT_OPTS = {
    :hash_secret => ":class/:attachment/:id",
    :styles => {
      :thumb => {:geometry => "125x185#", :processors => [:cropper]},
      :large => {:geometry => "240x319>"},
      :micro => {:geometry => "50x50#", :processors => [:cropper]}
    },
    :default_url => DEFAULT_AVATAR_URL,
    :path => "#{Rails.root}/tmp/:class/:attachment/:id/:style"
  }

   PAPERCLIP_STORAGE_OPTIONS = {
    :path   => "/:class/:attachment/:id/:style",
    :storage => :s3,
    :s3_credentials => {
      :access_key_id => AppConfig.aws['access_key_id'],
      :secret_access_key => AppConfig.aws['secret_access_key'],
      :bucket => AppConfig.aws['bucket']
    }
  }

  if AppConfig.aws && ! Rails.env.test?
    has_attached_file :avatar, ATTACHMENT_OPTS.merge(PAPERCLIP_STORAGE_OPTIONS)
  else
    has_attached_file :avatar, ATTACHMENT_OPTS
  end

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :name, :uid, :provider, :tagline, :avatar, :initial_provider,
                  :nickname, :access_code, :email_preferences
  attr_accessible :delete_avatar, :crop_x, :crop_y, :crop_w, :crop_h

  validates_attachment_content_type :avatar, :content_type => /image/
  validates :nickname,
            :presence => true,
            :uniqueness => true
  validates_format_of :nickname,
                      :with => /\A#{NICKNAME_REGEXP}\Z/,
                      :message => "can only be alphanumeric with no spaces"
  validates :tagline, :length => { :maximum => 60 }

  before_validation :generate_nickname, :on => :create
  before_save :possibly_delete_avatar
  before_update :reprocess_avatar, :if => :cropping?
  after_create :reserve_access_code

  scope :nicknamed,  lambda { |*nicknames| where(:nickname => nicknames) }
  scope :followed_by, lambda { |user|
    joins(:followers).where(:relationships => {:follower_id => user.id})
  }
  scope :ignore,  lambda { |users|
    where("users.id not in (?)", users) unless users.blank?
  }
  scope :limited, lambda { |page, count| page(page).per(count) unless page.nil? }

  scope :registered_around, lambda { |date|
    where('date(created_at) = ?', date)
  }
  scope :pending, where(:active => false)

  def self.access_code
    allowed_access_codes.first
  end

  def self.allowed_access_codes
    @codes ||= YAML.load_file(ACCESS_CODES_PATH)
  end

  def self.create_with_social_connection(params)
    transaction {
      user_params = params.slice(:access_code, :email, :name, :nickname).
        merge!(:initial_provider => params[:provider])
      sc_params   = params.slice(:provider, :token, :uid)

      user = create(user_params)
      user.social_connections.create!(sc_params) if user.persisted?

      user
    }
  end

  def self.filter(nick_or_name)
    if nick_or_name.present?
      where('users.nickname ilike :nn or
             users.name ilike :nn', :nn => "#{nick_or_name}%")
    else
      scoped
    end
  end

  def self.filter_by_name(name)
    where(['name ilike ?', "#{name}%"])
  end

  def self.find_by_slug(slug)
    where(:nickname => slug).first
  end

  def self.following_ids(follower_id)
    if !follower_id.blank?
      # FIXME: should get these ids without loading users
      User.includes(:following).find(follower_id).following.map(&:id)
    else
      []
    end
  end

  def self.named(name_or_names)
    where(:name => name_or_names)
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      data = session['devise.provider_data']

      if data
        case data[:provider]
        when 'twitter'
          if user.email.present?
            user.access_code      = data[:access_code]
            user.initial_provider = data[:provider]
            user.name             = data[:name]
            user.nickname         = data[:nickname]

            if user.valid?
              user.social_connections.
                build data.slice(:provider, :uid, :token, :token_secret)
            end
          end
        else
          raise "Don't know how to handle #{data.inspect}"
        end
      end
    end
  end

  def self.with_social_connection(provider, uid)
    users = joins(:social_connections)
      .where(:social_connections => {:provider => provider, :uid => uid})
      .readonly(false)

    if Array === uid
      users
    else
      users.first
    end
  end

  # Search for users matching the given name.
  #
  # @param [String] name the user name to search for
  #
  # @return a (possibly empty) list of users
  def self.with_text(name)
    q  = connection.quote_string(name).gsub(/\W/, ' ').strip.gsub(/\s+/, '|')

    if q.blank?
      where('1 = 0')
    else
      ts = "to_tsquery('english', '#{q}:*')"

      select("users.*,
            ts_rank(to_tsvector('english', users.name), #{ts}) name_rank").
        where("to_tsvector('english', users.name || users.nickname) @@ #{ts}").
        order('name_rank desc')
    end
  end

  def as_json(opts = nil)
    opts ||= {}

    method_names = Array.wrap(opts[:methods]).map { |n| n if respond_to?(n.to_s) }.compact
    method_hash = method_names.map { |n| [n, send(n)] }

    {:id               => id,
     :name             => name,
     :nickname         => nickname,
     :url              => url,
     :avatar_micro_url => avatar.url(:micro),
     :avatar_thumb_url => avatar.url(:thumb),
     :followers_count  => followers.count,
     :followers        => followers.limit(10).map(&UserSerializers::Summary),
     :following_count  => following.count,
     :following        => following.limit(10).map(&UserSerializers::Summary),
     :ripple_count     => ripple_count,
     :splash_count     => splash_count,
     :splash_score     => splash_score,
     :slug             => slug,
     :referral_url     => "#{AppConfig.preferred_host}/r/#{referral_code}",
     :score            => splash_score,
     :tagline          => tagline}.merge(Hash[method_hash]).tap { |h|

     if respond_to?(:relationship) &&
        ! Array(opts[:except]).include?(:relationship)
       h[:relationship] = relationship.as_json
     end
    }
  end

  def avatar_exists_or_able_to_download?
    !(self.avatar_url == DEFAULT_AVATAR_URL)
  end

  def avatar_geometry(style = :thumb)
    @geometry ||= {}

    @geometry[style] ||= Paperclip::Geometry.new(avatar.image_size(style).split('x').first,
                                                  avatar.image_size(style).split('x').last)
  end

  def avatar_url(style=:thumb)
    avatar.url(style)
  end

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def facebook_suggestions
    if social_connection('facebook')
      friends = FbGraph::User.me(social_connection('facebook').token).friends

      User.with_social_connection('facebook', friends.map(&:identifier)).
        value_of(:id)
    else
      []
    end
  rescue FbGraph::InvalidToken
    []
  end

  def first_name
    name.split(/\s+/).first
  end

  def follow(followed_id)
    follow_all([followed_id]).first
  end

  ##
  # Public: Follow all given users.
  #
  # users - an ActiveRecord::Relation working as a user filter,
  #         or a list of user ids
  #
  # Returns the relationships that were created.
  def follow_all(users)
    ids = if users.respond_to?(:value_of)
            users.value_of(:id)
          else
            users
          end

    rs = ids.map { |id| relationships.create(followed_id: id) }

    recompute_splashboard :add, ids

    ids.each { |id| suggested_users.delete id }
    write_attribute :suggested_users, suggested_users
    delay.update_suggestions

    save!

    rs
  end

  def followed(followed_id)
    relationships.find_by_followed_id(followed_id)
  end

  def following?(followed)
    !!followed(followed)
  end

  def has_social_connections?
    !social_connections.length.zero?
  end

  def ignore_suggested(user_id)
    user_id = user_id.to_i

    write_attribute(:ignore_suggested_users, ignore_suggested_users << user_id)
    suggested_users.delete(user_id)
    write_attribute(:suggested_users, suggested_users)
    save!
  end

  def ignore_suggested_users
    read_attribute(:ignore_suggested_users) || []
  end

  def email_preferences
    read_attribute(:email_preferences) || DEFAULT_EMAIL_PREFERENCES
  end

  def email_preference(key)
    email_preferences[key] == 'true'
  end

  def invite(code)
    UserMailer.delay.invite self, code

    destroy if social_connections.length.zero?
  end

  def merge_account(user)
    if self != user
      Notification.for(user).update_all :notified_id => self.id
      Notification.from(user).update_all :notifier_id => self.id
      Notification.from(user).for(user).map(&:destroy)

      Splash.for(user).update_all :user_id => self.id

      user.comments.update_all :author_id => self.id

      Relationship.with_followers(user)
        .ignore(following.map(&:id) << self.id)
        .update_all(:follower_id => self.id)
      Relationship.with_following(user)
        .ignore_followers(followers.map(&:id) << self.id)
        .update_all(:followed_id => self.id)

      user.social_connections.update_all :user_id => self.id
      user.destroy
      save!
    else
      raise "Trying to merge a user's account with itself: #{id}"
    end
  end

  def splashed?(track)
    case track
    when Track
      splashed_tracks_hash[track.id]
    else
      splashed_tracks_hash[track]
    end
  end

  def password_required?
    initial_provider.blank? && super
  end

  def recommended_users(max)
    social = social_connections.inject([]) { |a, c|
      begin
        users = User.
          where(:id => suggested_users).
          with_social_connection(c.provider, c.friends.map(&:uid)).
          limit(max)

        a.concat(users)
      rescue FbGraph::InvalidToken
        a
      end
    }

    others = User.where(:id => suggested_users - social.map(&:id)).limit(max)

    social.concat(others).first(max)
  end

  # Declarative Authorization user roles
  DEFAULT_ROLES = [:guest, :user].freeze
  def role_symbols
    roles = DEFAULT_ROLES.dup
    roles << :superuser if superuser?
    roles
  end

  def splash_suggestions
    # the users followed by people I am following, but whom I am not already following.
    Relationship.select('DISTINCT relationships.followed_id')
      .with_followers(following.map(&:id))
      .map(&:followed_id)
  end

  def slug
    nickname
  end

  def social_connection(provider)
    social_connections.detect { |s| s.provider == provider.to_s }
  end

  def add_suggestions(user_ids)
    suggest_users(Array(user_ids) | suggested_users)
  end

  def suggest_users(user_ids = default_user_suggestions)
    update_attribute :suggested_users, user_ids - ignored_user_ids
  end

  def ignored_user_ids
    following_ids + ignore_suggested_users + [id]
  end

  def default_user_suggestions
    facebook_suggestions | splash_suggestions
  end

  def suggested_users
    read_attribute(:suggested_users) || []
  end

  def suggestions_count
    suggested_users.count
  end

  # to_label for ActiveScaffold
  def to_label
    email
  end

  def to_params
    slug || super
  end

  def unfollow(followed_id)
    r = followed(followed_id).try(:destroy)
    recompute_splashboard(:subtract, followed_id)
    ignore_suggested(followed_id)
    r
  end

  def update_suggestions
    suggest_users
    followers.each &:suggest_users
  end

  def update_with_password(attrs = {})
    if attrs[:password].blank?
      attrs.delete(:password)
      attrs.delete(:password_confirmation) if
        attrs[:password_confirmation].blank?
    end

    update_attributes(attrs)
  end

  def setting(name)
    (settings || {})[name]
  end

  def update_setting(name, value)
    self.settings       ||= {}
    self.settings[name]   = value

    update_attribute :settings, self.settings
  end

  def url
    nickname
  end

  private

  def access_code_required?
    ! Rails.env.test?
  end

  def check_existence(name)
    User.exists?(:nickname => name) ? nil : name
  end

  def generate_nickname
    self.nickname ||= check_existence(to_slug(self.name)) \
                      || check_existence(to_slug(self.email)) \
                      || rand(36**6).to_s(36)
  end

  def nickname_needed?
    nickname.blank? && active?
  end

  def possibly_delete_avatar
    self.avatar = nil if self.delete_avatar == "1" && !self.avatar.dirty?
  end

  def reprocess_avatar
    avatar.reprocess!
  end

  def reserve_access_code
    AccessRequest.reserve access_code, self

    nil
  end

  def to_slug(string)
    string.strip.gsub(/@.*/, "").gsub(/\W+/, '_').downcase if string.present?
  end
end
