class FriendsController < ApplicationController
  PER_PAGE = 10

  def index
    sc = current_user.social_connection('facebook')

    respond_to { |f|
      f.html {
        if sc
          @social = sc.as_json(:only => [:token])
        else
          @social = nil

          session[:user_return_to] = request.url
        end
      }

      f.json {
        render :json => [], :status => :unauthorized unless sc

        token   = sc.token
        friends = FbGraph::User.me(token).friends
        filter  = params[:with_text]

        friends.select! { |f| f.name.match(/#{filter}/i) } if filter

        fsh   = friends.hash_by(&:identifier)
        users = User.with_social_connection('facebook', fsh.keys).by_score

        missing = fsh.keys - users.map { |u| u.social_connection('facebook').uid }

        rels = current_user.relationships.with_following(users.map(&:id))
        relh = rels.hash_by(&:followed_id)

        @users = paginate(users.map { |u|
          j = u.as_json

          j[:relationship] = (relh[u.id] ||
                              {:follower_id => current_user.id,
                               :followed_id => u.id}).as_json

          j
        } + friend_hashes(fsh.values_at(*missing)))

        render :json => @users
      }
    }
  end

  private

  def friend_hashes(friends)
    friends.map { |f|
      {:name             => f.name,
       :avatar_micro_url => f.picture('square'),
       :uid              => f.identifier,
       :origin           => 'facebook'}
    }
  end

  def paginate(list)
    start = (current_page - 1) * PER_PAGE

    list[start, PER_PAGE] || []
  end
end
