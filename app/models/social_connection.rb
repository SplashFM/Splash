class SocialConnection < ActiveRecord::Base
  belongs_to :user
  validates :uid, :uniqueness => true

  def self.with_provider(provider)
    where(:provider => provider).first
  end

  alias_method :refresh, :update_attributes!
end
