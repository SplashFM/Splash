class SocialController < ApplicationController
  skip_before_filter :require_user
  respond_to :json
  FACEBOOK_API_URL = "https://graph.facebook.com/me?access_token="
  
  def signin_fb
		if params[:access_token].present?
			@data = HTTParty.get(FACEBOOK_API_URL + params[:access_token]).parsed_response
			if @data["error"].present?
				if  @data["error"]["message"].present?
				  error_msg =  {:error =>  @data["error"]["message"]} 
				else
				 error_msg =  {:error=>"some thing went wrong"} 
				end
				respond_with (error_msg)
				
			else
			
				fb_uid = @data["id"]		
				email = @data["email"]
				name = @data["name"]
				provider = "facebook"
				access_token = params[:access_token]
			
				if user = User.with_social_connection(provider, fb_uid)
					respond_with user
				else
				
				 ft = {:provider=>"facebook",
					 :uid=>fb_uid,
					 :token=>access_token,
					 :access_code=>nil,
					 :email=>email,
					 :name=>name,
					 :nickname=>nil } 
			
					user = User.create_with_social_connection(ft)
					
						 
				 respond_with user
				end				
			end	
		end
	end



end
