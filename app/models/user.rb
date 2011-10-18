require 'redis_record'
require 'testable_search'
require 'open-uri'

class User < ActiveRecord::Base
  include RedisRecord
  extend TestableSearch

  DEFAULT_AVATAR_URL = '/images/dummy_user.png'

  redis_counter :ripple_count

  has_many :relationships, :foreign_key => 'follower_id', :dependent => :destroy
  has_many :following, :through => :relationships, :source => :followed

  has_many :reverse_relationships, :foreign_key => 'followed_id',
                                   :class_name => 'Relationship',
                                   :dependent => :destroy
  has_many :followers, :through => :reverse_relationships
  has_many :uploaded_tracks,
           :class_name  => 'UndiscoveredTrack',
           :foreign_key => 'uploader_id'

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :name, :uid, :provider, :tagline, :avatar

  validates :name, :presence => true, :on => :update
  validates :tagline, :length => { :maximum => 60 }

  has_attached_file :avatar,
                    :styles  => { :thumb => "100x100#", :large => "240x300>" },
                    :default_url => DEFAULT_AVATAR_URL,
                    :processors => [:cropper]

  before_save :possibly_delete_avatar

  extend FriendlyId
  friendly_id :name, :use => :slugged

  attr_accessor :delete_avatar, :crop_x, :crop_y, :crop_w, :crop_h
  attr_accessible :delete_avatar, :crop_x, :crop_y, :crop_w, :crop_h

  after_update :reprocess_avatar, :if => :cropping?
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

  def follow(followed)
    relationships.create(:followed => followed)
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

  def search_result_type
    :user
  end

  # Search for users matching the given name.
  #
  # @param [String] name the user name to search for
  #
  # @return a (possibly empty) list of users
  def self.with_text(name)
    search(:name => name)
  end

  def self.find_for_oauth(access_token)
    name     = access_token['user_info']['name']
    provider = access_token['provider']
    uid      = access_token['uid']
    email    = access_token['extra'].try(:[], 'user_hash').try(:[], 'email')

    user = User.find_by_provider_and_uid(provider, uid)
    unless user
      user = User.new(:name => name, :email => email,
                      :password => Devise.friendly_token[0,20],
                      :provider => provider, :uid => uid)
    end
    user.save unless email.blank?
    user
  end

  def password_required?
    self.provider.blank? && super
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if session['devise.provider_data']
        data = session['devise.provider_data']

        user.provider = data['provider']
        user.uid = data['uid']

        user_hash = data['extra']['user_hash'] if data['extra']

        if user_hash
          user.name = user_hash['name']
          user.email = user_hash['email']
        else
          user.name = data['user_info']['name'] if data['user_info']
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

  def avatar_url(style=:thumb)
    if avatar.exists?
      avatar.url(style)
    elsif !provider.blank?
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
    !self.avatar.exists? && !self.provider.blank?
  end

  def avatar_exists_or_able_to_download?
    !(self.avatar_url == DEFAULT_AVATAR_URL)
  end

  def provider_avatar_url
    if provider == 'facebook'
      "http://graph.facebook.com/#{self.uid}/picture"
    elsif provider == 'twitter'
      "http://api.twitter.com/1/users/profile_image/#{self.uid}.json"
    else
      nil
    end
  end

  private
  def possibly_delete_avatar
    self.avatar = nil if self.delete_avatar == "1" && !self.avatar.dirty?
  end

  def reprocess_avatar
    avatar.reprocess!
  end
end
