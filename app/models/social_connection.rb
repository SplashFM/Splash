class SocialConnection < ActiveRecord::Base
  extend Forwardable

  belongs_to :user

  def_delegators :remote, :friends, :avatar_url, :splashed

  validates :uid, :uniqueness => true

  def self.with_provider(provider)
    where(:provider => provider).first
  end

  alias_method :refresh, :update_attributes!

  def remote
    @remote ||= self.class.const_get(provider.classify).new(self)
  end

  class Facebook
    def self.app
      @app ||= FbGraph::Application.new(AppConfig.facebook['key'])
    end

    def initialize(connection)
      @me = FbGraph::User.new(connection.uid, :access_token => connection.token)
    end

    def avatar_url
      @me.picture(:large)
    end

    def friends(filter = nil, cache = Rails.cache)
      key     = "facebook:friends:#{@me.identifier}"
      friends = cache.fetch(key, :expires_in => 24.hours) {
        @me.friends.map { |f| {:name => f.name, :identifier => f.identifier} }
      }

      (filter ? friends.select { |f| f[:name].match(/#{filter}/i) } : friends).
        map { |f| FbGraph::User.new(f[:identifier], f) }
    end

    def splashed(splash, router)
      @me.og_action! self.class.app.og_action(:splash),
                     :song => router.splash_url(splash)
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
      @uid = connection.uid
    end

    def avatar_url
      "http://api.twitter.com/1/users/profile_image/#{@uid}.json?size=original"
    end

    def friends(filter = nil, cache = Rails.cache)
      []
    end
  end
end
