class TagsController < ApplicationController
  def index
    genres  = Genre.filter(params[:q])
    artists = Artist.filter(params[:q])
    hashes  = (artists + genres).map { |t|
      t.as_json(:only => [:id, :name]).merge!(:type => t.class.name.underscore)
    }

    render :json => hashes
  end
end
