require 'redis_record'
require 'testable_search'
require 'open-uri'
require 'cropper'

class User < ActiveRecord::Base
  include RedisRecord
  extend TestableSearch

  ACCESS_CODES_PATH = File.join(Rails.root, %w(config access_codes.yml))

  MAX_SCORE       = 99
  NICKNAME_REGEXP = '[A-Za-z\d_\-.]+'

  DEFAULT_AVATAR_URL = '/images/dummy_user_:style.png'
  AVATAR_WIDTH = 125
  AVATAR_HEIGHT = 185
  SUGGESTED_USERS_PER_PAGE = 3

  scope :followed_by, lambda { |user|
    joins(:followers).where(:relationships => {:follower_id => user.id})
  }
  scope :ignore,  lambda { |users| where("id not in (?)", users) unless users.blank? }
  scope :limited, lambda { |page, count| page(page).per(count) unless page.nil? }

  scope :registered_around, lambda { |date|
    where('date(created_at) = ?', date)
  }
  scope :pending, where(:active => false)

  redis_sorted_field :influence
  redis_counter :ripple_count
  redis_counter :splash_count
  redis_hash :splashed_tracks
  serialize :ignore_suggested_users, Array
  serialize :suggested_users, Array

  attr_accessor :access_code

  has_many :relationships, :foreign_key => 'follower_id', :dependent => :destroy
  # The users I am following.
  has_many :following, :through => :relationships, :source => :followed

  has_many :reverse_relationships, :foreign_key => 'followed_id',
                                   :class_name => 'Relationship',
                                   :dependent => :destroy

  # The users who are following me.
  has_many :followers, :through => :reverse_relationships
  has_many :uploaded_tracks,
           :class_name  => 'UndiscoveredTrack',
           :foreign_key => 'uploader_id'

  has_many :comments, :foreign_key => :author_id
  has_many :social_connections,
           :after_add => :maybe_fetch_avatar,
           :dependent => :destroy

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :name, :uid, :provider, :tagline, :avatar, :initial_provider,
                  :nickname, :access_code

  before_validation :generate_nickname, :on => :create

  validates :nickname,
            :presence => true,
            :uniqueness => true,
            :on => :update
  validates_format_of :nickname,
                      :with => /\A#{NICKNAME_REGEXP}\Z/,
                      :message => "can only be alphanumeric with no spaces",
                      :on => :update
  validates :tagline, :length => { :maximum => 60 }

  validate  :validate_access_code, :on => :create

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

  validates_attachment_content_type :avatar, :content_type => /image/

  before_save :possibly_delete_avatar

  attr_accessor :delete_avatar, :crop_x, :crop_y, :crop_w, :crop_h
  attr_accessible :delete_avatar, :crop_x, :crop_y, :crop_w, :crop_h

  before_update :reprocess_avatar, :if => :cropping?

  scope :nicknamed,  lambda { |*nicknames| where(:nickname => nicknames) }

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

            user.social_connections.
              build data.slice(:provider, :uid, :token, :token_secret)
          end
        else
          raise "Don't know how to handle #{data.inspect}"
        end
      end
    end
  end

  def self.recompute_all_splashboards
    User.find_each(:batch_size => 100) {|u| u.recompute_splashboard }
  end

  def self.recompute_influence
    reset_sorted_influence

    update_influences(User.select(:id).map(&:id))
  end

  def self.recompute_ripple_counts
    reset_ripple_counts

    find_each(:batch_size => 100) {|u|
      update_ripple_count u.id, u.slow_ripple_count
    }
  end

  def self.recompute_splash_counts
    reset_splash_counts

    find_each(:batch_size => 100) {|u|
      update_splash_count u.id, u.slow_splash_count
    }
  end

  def self.recompute_splashed_tracks
    reset_splashed_tracks

    find_each(:batch_size => 100) { |u|
      u.reset_splashed_tracks_hash!
      u.recompute_splashboard
    }
  end

  def self.top_splashers(page, num_records)
    sorted_by_influence(page, num_records)
  end

  def self.update_influences(ids)
    scs    = splash_counts(ids) || []
    rcs    = ripple_counts(ids) || []
    ids.zip(scs, rcs).each { |(id, s, r)|
      update_sorted_influence(id, s.to_i + r.to_i)
    }
  end

  def self.with_social_connection(provider, uid)
    joins(:social_connections)
      .where(:social_connections => {:provider => provider, :uid => uid})
      .readonly(false)
      .first
  end

  # Search for users matching the given name.
  #
  # @param [String] name the user name to search for
  #
  # @return a (possibly empty) list of users
  def self.with_text(name)
    q = connection.quote_string(name)
    select("users.*, ts_rank(to_tsvector('english', users.name),
            plainto_tsquery('english', '#{q}')) name_rank").
    where('users.name ilike ?', "#{name}%").
    order('name_rank desc')
  end

  def as_json(opts = nil)
    opts ||= {}

    method_names = Array.wrap(opts[:methods]).map { |n| n if respond_to?(n.to_s) }.compact
    method_hash = method_names.map { |n| [n, send(n)] }

    {:id               => id,
     :name             => name,
     :nickname         => nickname,
     :url              => "/#{slug}",
     :avatar_micro_url => avatar.url(:micro),
     :avatar_thumb_url => avatar.url(:thumb),
     :ripple_count     => ripple_count,
     :splash_count     => splash_count,
     :slug             => slug,
     :referral_url     => "#{AppConfig.preferred_host}/r/#{referral_code}",
     :score            => splash_score}.merge(Hash[method_hash])
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

  def default_social_connection
    social_connections.first
  end

  def facebook_suggestions(ignore=[])
    if has_social_connection?('facebook')
      facebook_friends = FbGraph::User.me(social_connection('facebook').token).friends
      ids = User.where(:name => facebook_friends.map(&:name))
                .ignore(ignore)
                .map(&:id)

      write_attribute(:suggested_users, suggested_users | ids) unless ids.blank?
    end
  end

  def fetch_avatar(social_connection = nil)
    begin
      Tempfile.open('avatar') { |f|
        f.binmode
        f.write open(URI.encode(provider_avatar_url)).read

        self.update_attribute(:avatar, f)
      }
    rescue OpenURI::HTTPError => e
      HoptoadNotifier.notify e
    end
  end

  def fetch_avatar_needed?
    !avatar? && has_social_connections?
  end

  def follow(followed_id)
    suggested_users.delete(followed_id)
    write_attribute(:suggested_users, suggested_users)
    r = relationships.create(:followed_id => followed_id)
    recompute_splashboard(:add, followed_id)
    self.delay.update_suggestions
    save!
    r
  end

  def followed(followed_id)
    relationships.find_by_followed_id(followed_id)
  end

  def following?(followed)
    !!followed(followed)
  end

  def has_social_connection?(provider)
    social_connection provider
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

  def influence_score
    total_users = User.count

    if influence_rank
      (90 * (((total_users - influence_rank) / total_users.to_f) ** 2)).floor
    else
      0
    end
  end

  def invite(code)
    UserMailer.delay.invite self, code

    destroy if social_connections.length.zero?
  end

  def maybe_fetch_avatar(_ = nil)
    fetch_avatar if fetch_avatar_needed?
  end

  def merge_account(user)
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

  def provider_avatar_url
    sc = default_social_connection

    case sc.try(:provider)
    when 'facebook'
      "http://graph.facebook.com/#{sc.uid}/picture?type=large"
    when 'twitter'
      "http://api.twitter.com/1/users/profile_image/#{sc.uid}.json?size=original"
    else
      nil
    end
  end

  def recommended_users(page=0)
    User.where("id IN (?)", suggested_users)
        .limited(page, SUGGESTED_USERS_PER_PAGE)
  end

  def recompute_splashboard(operation = nil, followed = nil)
    # TODO: there is a more efficient way to add or subtract the other users history,
    # but this works for now.
    reset_top_tracks!
  end

  def reset_splashed_tracks_hash!
    Splash.for_users(id).select(:track_id).map(&:track_id).each{|i|
      record_splashed_track(i)
    }
  end

  def reset_top_tracks!
    replace_summed_splashed_tracks(following_ids)
  end

  # Declarative Authorization user roles
  DEFAULT_ROLES = [:guest, :user].freeze
  def role_symbols
    roles = DEFAULT_ROLES.dup
    roles << :superuser if superuser?
    roles
  end

  def search_result_type
    :user
  end

  def splash_suggestions(ignore=[])
    # the users followed by people I am following, but whom I am not already following.
    relationships = Relationship.select('DISTINCT relationships.followed_id')
                            .with_followers(following.map(&:id))
                            .ignore(ignore + [self.id])
    ids = relationships.map(&:followed_id)

    write_attribute(:suggested_users, suggested_users | ids) unless ids.blank?
  end

  def slow_ripple_count
    Splash.for_users(id).map(&:ripple_count).sum
  end

  def slow_splash_count
    Splash.for_users(id).count
  end

  def slug
    nickname
  end

  def social_connection(provider)
    social_connections.with_provider provider
  end

  def splash_score
    s = influence_score + 10

    s > MAX_SCORE ? MAX_SCORE : s
  end

  def splashed_tracks_hash
    splashed_tracks.inject({}) {|m, i| m[i.to_i] = true; m}
  end

  def suggest_users
    ignore = following.map(&:id) + ignore_suggested_users

    facebook_suggestions(ignore)
    splash_suggestions(ignore)
    save!
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

  def top_tracks(page=1, num_records=20)
    scores = summed_splashed_tracks(page, num_records)

    if scores.present?
      ids, _ = *scores.transpose
      cache = Hash[*Track.where(:id => ids).map { |t| [t.id, t] }.flatten]

      scores.map { |(id, score)|
        cache[id.to_i].tap { |t| t.scoped_splash_count = score }
      }
    else
      []
    end
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

  private

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

  def to_slug(string)
    string.strip.gsub(/@.*/, "").gsub(/\W+/, '_').downcase if string.present?
  end

  def validate_access_code
    unless AccessRequest.code?(access_code)
      errors.add(:access_code, 'is invalid')
    end
  end
end
