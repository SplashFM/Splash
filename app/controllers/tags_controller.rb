class TagsController < ApplicationController
  MAX_TAGS = 5

  def index
    # TODO: optimize
    genres  = Genre.filter(params[:q]).limit(MAX_TAGS)
    artists = Artist.filter(params[:q]).limit(MAX_TAGS)
    hashes  = (artists + genres).sort_by(&:name).map { |t|
      t.as_json(:only => [:id, :name]).merge!(:type => t.class.name.underscore)
    }.first(MAX_TAGS)

    render :json => hashes
  end
end
