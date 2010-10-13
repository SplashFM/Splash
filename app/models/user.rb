class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :confirmable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  has_attached_file :avatar, :styles => { :thumb => ["64x64>", :png] }

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
end
