class TagsController < ApplicationController
  MAX_TAGS = 5
  def index
    # TODO: optimize
    tags    = ActsAsTaggableOn::Tag.named_like(params[:q]).limit(MAX_TAGS)
    #artists = Artist.filter(params[:q]).limit(MAX_TAGS)
    
    hashes  = tags.sort_by(&:name).map { |t|
      {:value => t.name}
    }.first(MAX_TAGS)
    
    render :json => hashes
  end
  
end
