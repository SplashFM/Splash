require 'testable_search'

class User < ActiveRecord::Base
  extend TestableSearch


  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :confirmable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :name, :uid, :provider, :tagline

  validates :name, :presence => true, :on => :update
  validates :tagline, :length => { :maximum => 60 }

  has_attached_file :avatar,
                    :styles => { :thumb => ["64x64>", :png] },
                    :default_url => "/images/dummy_user.png"

  before_save :possibly_delete_avatar
  attr_accessor :delete_avatar
  attr_accessible :delete_avatar

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

  private
  def possibly_delete_avatar
    self.avatar = nil if self.delete_avatar == "1" && !self.avatar.dirty?
  end
end
