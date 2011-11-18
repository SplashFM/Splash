require 'redis_record'
require 'testable_search'
require 'open-uri'

class User < ActiveRecord::Base
  include RedisRecord
  extend TestableSearch

  DEFAULT_AVATAR_URL = '/images/dummy_user.png'
  SUGGESTED_USERS_PER_PAGE = 3

  scope :ignore,  lambda { |users| where("id not in (?)", users) unless users.blank? }
  scope :limited, lambda { |page, count| page(page).per(count) unless page.nil? }

  redis_sorted_field :influence
  redis_counter :ripple_count
  redis_counter :splash_count
  redis_hash :splashed_tracks
  serialize :ignore_suggested_users, Array
  serialize :suggested_users, Array

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
  has_many :social_connections, :dependent => :destroy

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :name, :uid, :provider, :tagline, :avatar, :initial_provider,
                  :nickname

  before_validation :generate_nickname

  validates :nickname, :presence => true, :uniqueness => true
  validates_format_of :nickname,
                      :with => /^[A-Za-z\d_\-]+$/,
                      :message => "can only be alphanumeric with no spaces"
  validates :tagline, :length => { :maximum => 60 }

  has_attached_file :avatar,
                    :styles => {
                      :thumb => {:geometry => "125x185#", :processors => [:cropper]},
                      :large => {:geometry => "240x300>"}
                    },
                    :default_url => DEFAULT_AVATAR_URL

  before_save :possibly_delete_avatar

  attr_accessor :delete_avatar, :crop_x, :crop_y, :crop_w, :crop_h
  attr_accessible :delete_avatar, :crop_x, :crop_y, :crop_w, :crop_h

  after_update :reprocess_avatar, :if => :cropping?

  scope :with_slugs, lambda { |*slugs| where(:nickname => slugs) }

  def self.filter_by_name(name)
    where(['name ilike ?', "#{name}%"])
  end

  def self.filter(name)
    filter_by_name(name)
  end

  def self.named(name_or_names)
    where(:name => name_or_names)
  end

  def self.top_splashers(page, num_records)
    sorted_by_influence(page, num_records)
  end

  def self.update_influence(ids)
    scs    = splash_counts(ids) || []
    rcs    = ripple_counts(ids) || []
    scores = ids.zip(scs, rcs).map { |(id, s, r)|
      [id, s.to_i + r.to_i] }

    update_influence_scores scores
  end

  def self.find_by_slug(slug)
    where(:nickname => slug).first
  end

  def splashed_tracks_hash
    splashed_tracks.inject({}) {|m, i| m[i.to_i] = true; m}
  end

  def reset_splashed_tracks_hash!
    Splash.for_users(id).select(:track_id).map(&:track_id).each{|i|
      record_splashed_track(i)
    }
  end

  def reset_top_tracks!
    replace_summed_splashed_tracks(following_ids)
  end

  def top_tracks(page=1, num_records=20)
    ids = summed_splashed_tracks(page, num_records).map(&:to_i)
    cache = Hash[*Track.where(:id => ids).map { |t| [t.id, t] }.flatten]

    ids.map { |id| cache[id] }
  end

  def ignore_suggested_users
    read_attribute(:ignore_suggested_users) || []
  end

  def suggested_users
    read_attribute(:suggested_users) || []
  end

  def suggestions_count
    suggested_users.count
  end

  def recommended_users(page=0)
    User.where("id IN (?)", suggested_users)
        .limited(page, SUGGESTED_USERS_PER_PAGE)
  end

  def suggest_users
    ignore = following.map(&:id) + ignore_suggested_users

    facebook_suggestions(ignore)
    splash_suggestions(ignore)
    save
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

  def splash_suggestions(ignore=[])
    # the users followed by people I am following, but whom I am not already following.
    relationships = Relationship.select('DISTINCT relationships.followed_id')
                            .with_followers(following.map(&:id))
                            .ignore(ignore + [self.id])
    ids = relationships.map(&:followed_id)

    write_attribute(:suggested_users, suggested_users | ids) unless ids.blank?
  end

  def as_json(opts = {})
    {:id            => id,
     :name          => name,
     :nickname      => nickname,
     :url          => "/#{slug}",
     :avatar_search => avatar.url(:thumb),
     :ripple_count  => ripple_count,
     :splash_count  => splash_count,
     :slug          => slug,
     :score         => splash_score}
  end

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def avatar_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(avatar.path(style)) unless avatar.path.blank?
  end

  def followed(followed)
    relationships.find_by_followed_id(followed)
  end

  def following?(followed)
    !!followed(followed)
  end

  def self.following_ids(follower_id)
    if !follower_id.blank?
      # FIXME: should get these ids without loading users
      User.includes(:following).find(follower_id).following.map(&:id)
    else
      []
    end
  end

  def follow(followed)
    suggested_users.delete(followed.id)
    write_attribute(:suggested_users, suggested_users)
    relationships.create(:followed => followed)
    followed.suggest_users
    suggest_users
    save
  end

  def unfollow(user)
    followed(user).try(:destroy)
  end

  def following_sample(count=0)
    max_offset = [0, following.count - count+1].max
    following.find :all,
                  :offset => max_offset,
                  :limit => count
  end

  def followers_sample(count=0)
    max_offset = [0, followers.count - count+1].max
    followers.find :all,
                  :offset => max_offset,
                  :limit => count
  end

  def ignore_suggested(user)
    write_attribute(:ignore_suggested_users, ignore_suggested_users << user.id)
    suggested_users.delete(user.id)
    write_attribute(:suggested_users, suggested_users)
    save
  end

  def influence_score
    total_users = User.count

    if influence_rank
      (90 * (((total_users - influence_rank) / total_users.to_f) ** 2)).floor
    else
      0
    end
  end

  def splash_score
    influence_score + 10
  end

  def search_result_type
    :user
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
    where(["to_tsvector('english', users.name) @@
            plainto_tsquery('english', ?)", name]).
    order('name_rank desc')
  end

  def self.with_social_connection(provider, uid)
    joins(:social_connections)
      .where(:social_connections => {:provider => provider, :uid => uid})
      .readonly(false)
      .first
  end

  def self.find_for_oauth(access_token)
    name     = access_token['user_info'].try(:[], 'name')
    email    = access_token['extra'].try(:[], 'user_hash').try(:[], 'email')
    nickname = access_token['user_info'].try(:[], 'nickname')
    provider = access_token['provider']
    uid      = access_token['uid']
    token    = access_token['credentials']['token']
    token_secret  = access_token['credentials'].try(:[], 'secret')

    user = User.with_social_connection(provider, uid)
    unless user
      user = User.new(:name => name, :email => email, :nickname => nickname,
                      :initial_provider => provider,
                      :password => Devise.friendly_token[0,20])
      user.social_connections.build(:provider => provider, :uid => uid,
                                    :token => token, :token_secret => token_secret)
      user.save unless email.blank?
      user.facebook_suggestions
    end

    user
  end

  def password_required?
    initial_provider.blank? && super
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if session['devise.provider_data']
        data = session['devise.provider_data']

        token_secret = data['credentials'].try(:[], 'secret')
        user.initial_provider = data['provider']
        user.social_connections.build(:provider => data['provider'],
                                      :uid => data['uid'],
                                      :token => data['credentials']['token'],
                                      :token_secret => token_secret)

        user_hash = data['extra']['user_hash'] if data['extra']

        if user_hash
          user.name = user_hash['name']
          user.email = user_hash['email']
        else
          user.name = data['user_info'].try(:[], 'name')
          user.nickname = data['user_info'].try(:[], 'nickname')
        end
      end
    end
  end

  # Declarative Authorization user roles
  DEFAULT_ROLES = [:guest, :user].freeze
  def role_symbols
    roles = DEFAULT_ROLES.dup
    roles << :superuser if superuser?
    roles
  end

  # to_label for ActiveScaffold
  def to_label
    email
  end

  def to_params
    slug || super
  end

  def slug
    nickname
  end

  def avatar_url(style=:thumb)
    if avatar.exists?
      avatar.url(style)
    elsif has_social_connections?
      provider_avatar_url
    else
      DEFAULT_AVATAR_URL
    end
  end

  def fetch_avatar
    begin
      self.update_attribute(:avatar, open(URI.encode(provider_avatar_url))) if fetch_avatar_needed?
    rescue OpenURI::HTTPError => e
      notify_hoptoad(e)
    end
  end

  def fetch_avatar_needed?
    !self.avatar.exists? && !self.initial_provider.blank?
  end

  def avatar_exists_or_able_to_download?
    !(self.avatar_url == DEFAULT_AVATAR_URL)
  end

  def provider_avatar_url
    if initial_provider == 'facebook' || (has_social_connection?('facebook') && initial_provider.blank?)
      "http://graph.facebook.com/#{social_connection('facebook').uid}/picture?type=large"
    elsif initial_provider == 'twitter' || has_social_connection?('twitter')
      "http://api.twitter.com/1/users/profile_image/#{social_connection('twitter').uid}.json?size=bigger"
    else
      nil
    end
  end

  def has_social_connections?
    !social_connections.length.zero?
  end

  def has_social_connection?(provider)
    social_connection provider
  end

  def social_connection(provider)
    social_connections.with_provider provider
  end

  private
  def possibly_delete_avatar
    self.avatar = nil if self.delete_avatar == "1" && !self.avatar.dirty?
  end

  def reprocess_avatar
    avatar.reprocess!
  end

  def generate_nickname
    self.nickname ||= check_existence(to_slug(self.name)) \
                      || check_existence(to_slug(self.email)) \
                      || rand(36**6).to_s(36)
  end

  def to_slug(string)
    if !string.blank?
      ret = string.strip
      ret.gsub!(/@/, "_at_")
      ret.gsub!(/\W+/, '_')
      ret = ret.split(".").first
      ret.downcase
    end
  end

  def check_existence(name)
    User.exists?(:nickname => name) ? nil : name
  end
end
