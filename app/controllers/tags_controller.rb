class TagsController < ApplicationController
  def index
    genres  = Genre.filter(params[:q])
    hashes  = genres.map { |g|
      g.as_json(:only => [:id, :name]).merge!(:type => 'genre')
    }

    render :json => hashes
  end
end
