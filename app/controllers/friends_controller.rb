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
        if sc
          fsh   = sc.friends(params[:with_text]).index_by(&:identifier)
          users = User.with_social_connection('facebook', fsh.keys).by_score

          missing  = fsh.keys - users.map { |u| u.social_connection('facebook').uid }
          withrels = Relationship.relate_to_follower(users, current_user)

          @users = paginate(withrels.map(&:as_json) +
            friend_hashes(fsh.values_at(*missing)))

          render :json => @users
        else
          render :json => [], :status => :unauthorized
        end
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
