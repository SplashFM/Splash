class TagsController < ApplicationController
  MAX_TAGS = 5
  def index
    # TODO: optimize
    
    tags =
      if params[:q].present?
        ActsAsTaggableOn::Tag.named_like(params[:q]).limit(MAX_TAGS)
      else
        Comment.tag_counts_on(:tags).limit(MAX_TAGS).order('count desc')
      end  
    hashes  = tags.sort_by(&:name).map { |t|
      {:value => t.name}
    }.first(MAX_TAGS)
    
    render :json => hashes
  end
  
end
