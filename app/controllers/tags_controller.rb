class TagsController < ApplicationController
  MAX_TAGS = 5
  SUGGEST_TAGS = 5
  def index
    # TODO: optimize
    hashes  = 
      if params[:q].present?
        ActsAsTaggableOn::Tag.named_like(params[:q]).limit(SUGGEST_TAGS)
                                     .sort_by(&:name).map { |t|
                                       {:value => t.name}
                                     }
      else
        tags = Comment.tag_counts_on(:tags).limit(MAX_TAGS).order('count desc')
                                     .map { |t|
                                       {:value => t.name}
                                     }
      end  

    render :json => hashes
  end
  
end
