class FriendsController < ApplicationController
  PER_PAGE = 10

  def index
    sc = current_user.social_connection('facebook')

    unless sc
      @social = nil
      @users  = []

      session[:user_return_to] = request.url

      render and return
    end

    token   = sc.token
    friends = FbGraph::User.me(token).friends
    filter  = params[:with_text]

    friends.select! { |f| f.name.match(/#{filter}/i) } if filter

    fsh   = Hash[*friends.map { |f| [f.identifier, f] }.flatten]
    users = User.
      with_social_connection('facebook', fsh.keys).
      by_score

    missing = fsh.keys - users.map { |u| u.social_connection('facebook').uid }

    rels = current_user.relationships.with_following(users.map(&:id))
    relh = Hash[*rels.map { |r| [r.followed_id, r] }.flatten]

    @social = sc.as_json(:only => [:token])
    @users = paginate(users.map { |u|
      j = u.as_json

      j[:relationship] = (relh[u.id] ||
                          {:follower_id => current_user.id,
                           :followed_id => u.id}).as_json

      j
    } + friend_hashes(fsh.values_at(*missing)))

    respond_to { |f|
      f.html { render }
      f.json { render :json => @users }
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
