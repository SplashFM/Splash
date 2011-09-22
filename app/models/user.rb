require 'testable_search'
require 'open-uri'

class User < ActiveRecord::Base
  extend TestableSearch


  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :confirmable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :name, :uid, :provider, :tagline, :avatar

  validates :name, :presence => true, :on => :update
  validates :tagline, :length => { :maximum => 60 }

  has_attached_file :avatar,
                    :styles => { :thumb => ["100x120>", :png] },
                    :default_url => "/images/dummy_user.png"

  before_save :possibly_delete_avatar

  attr_accessor :delete_avatar, :crop_x, :crop_y, :crop_w, :crop_h
  attr_accessible :delete_avatar, :crop_x, :crop_y, :crop_w, :crop_h

  after_update :reprocess_avatar, :if => :cropping?
  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def avatar_geometry(style = :original)
    @geometry ||= {}
    self.fetch_avatar unless self.avatar.exists?
    @geometry[style] ||= Paperclip::Geometry.from_file(avatar.path(style))
  end

  after_save 'confirm!', :if => :oauth_login?
  def oauth_login?
    !(provider.blank? || uid.blank?) && !self.confirmed?
  end

  # Search for users matching the given name.
  #
  # @param [String] name the user name to search for
  #
  # @return a (possibly empty) list of users
  def self.filtered(name)
    if use_slow_search?
      # We want to use memory-based sqlite3 for most tests.
      # This is ugly, but tests run faster.
      # Also see Track.filtered.

      where(:name => name)
    else
      search(:name => name)
    end
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

  def avatar_url(style=:thumb)
    if avatar.exists?
      avatar.url(style)
    else
      provider_avatar_url
    end
  end

  def fetch_avatar
    begin
      self.update_attribute(:avatar, open(URI.encode(provider_avatar_url)))
    rescue OpenURI::HTTPError => e
      logger.info "Exception raised: #{e}"
    end
  end

  def provider_avatar_url
    if provider == 'facebook'
      url = "http://graph.facebook.com/#{self.uid}/picture"
    elsif provider == 'twitter'
      url = "http://api.twitter.com/1/users/profile_image/#{self.uid}.json"
    else
      url = ''
    end
  end

  private
  def possibly_delete_avatar
    self.avatar = nil if self.delete_avatar == "1" && !self.avatar.dirty?
  end
end
