module Social
  module Facebook
    class FollowFriends
      def users
        User
      end

      def after_create(social_connection)
        return unless social_connection.provider == 'facebook'

        uids      = social_connection.friends.map(&:identifier)
        splashers = users.with_social_connection(:facebook, uids)

        social_connection.user.follow_all splashers
      end
    end

    SocialConnection.after_create FollowFriends.new
  end
end
