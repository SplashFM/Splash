class SocialController < ApplicationController
  skip_before_filter :require_user
  respond_to :json
  
  FACEBOOK_API_URL = "https://graph.facebook.com/me?access_token="
  TWITTER_API_URL = "https://api.twitter.com/1/users/show.json?user_id="
  
  def signin_fb
		if params[:token].present?
			ft = social_token_fb
			if ft[:error].present?
				respond_with ft
			else
				user = User.with_social_connection("facebook", ft[:uid])
				if user 
					user.social_connection("facebook").
						refresh params.slice(:token)
					
					respond_with user
				else
				  user = User.create_with_social_connection(ft)
					respond_with user
				end				
			end
		end
	end
	
	
  def signin_twitter
		if params[:token].present? and params[:uid].present? and params[:email].present? and params[:token_secret].present?
			user = User.with_social_connection("twitter", params[:uid])
			if user 
				user.social_connection("twitter").
					refresh params.slice(:token, :token_secret) 
				respond_with user
			else
				ft = social_token_twitter
				if ft[:error].present?
					respond_with ft
				else
					user = User.create_with_social_connection(ft)
					respond_with user
				end
			end				
		end
	end


private
	
	def social_token_fb
		@data = HTTParty.get(FACEBOOK_API_URL + params[:token]).parsed_response
	  if @data.present?
			if @data["error"].present?
				if  @data["error"]["message"].present?
				  ft =  {:error =>  @data["error"]["message"]} 
				else
				  ft =  {:error=>"some thing went wrong"} 
				end
			else
			ft = {:provider=>"facebook",
				 :uid=>@data["id"],
				 :token=>params[:token],
				 :access_code=>nil,
				 :email=>@data["email"],
				 :name=>@data["name"],
				 :nickname=>@data["username"] } 
			end
		end
	end


	
	def social_token_twitter
		@data = HTTParty.get(TWITTER_API_URL + params[:uid]).parsed_response
	  if @data.present?
			if @data["error"].present?
			  ft =  {:error =>  @data["error"]} 
			else
			   ft = {:provider=>"twitter",
				 :uid=>params[:uid],
				 :token=>params[:token],
				 :access_code=>nil,
				 :name=>@data["name"],
				 :email=>params[:email],
				 :nickname=>@data["screen_name"] } 
			end
		end
	end
	
end
