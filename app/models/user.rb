require 'testable_search'

class User < ActiveRecord::Base
  extend TestableSearch

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :confirmable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name

  validates :name, :presence => true, :on => :update

  has_attached_file :avatar, :styles => { :thumb => ["64x64>", :png] }
  before_save :possibly_delete_avatar
  attr_accessor :delete_avatar
  attr_accessible :delete_avatar

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

  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token['extra']['user_hash']

    if user = User.find_by_email(data["email"])
      user
    else
      user = User.create(:email => data["email"],
                          :password => Devise.friendly_token[0,20],
                          :name => access_token['user_info']['name'])
      user.confirm!
      user
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["user_hash"]
        user.email = data["email"]
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
