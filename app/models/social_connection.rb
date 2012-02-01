class SocialConnection < ActiveRecord::Base
  extend Forwardable

  belongs_to :user

  def_delegators :remote, :friends

  validates :uid, :uniqueness => true

  def self.with_provider(provider)
    where(:provider => provider).first
  end

  alias_method :refresh, :update_attributes!

  def remote
    @remote ||= self.class.const_get(provider.classify).new(self)
  end

  class Facebook
    def initialize(connection)
      @me = FbGraph::User.new(connection.uid, :access_token => connection.token)
    end

    def friends
      @me.friends
    end

    module FriendAttributes
      def uid
        identifier
      end

      FbGraph::User.send(:include, self)
    end
  end

  class Twitter
    def initialize(connection)
      @connection = connection
    end

    def friends
      []
    end
  end
end
