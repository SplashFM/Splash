class TagsController < ApplicationController
  MAX_TAGS = 6
  SUGGEST_TAGS = 5
  def index
    # TODO: optimize
    hashes  = 
      if params[:q].present?
        ActsAsTaggableOn::Tag.named_like(params[:q]).limit(SUGGEST_TAGS).sort_by(&:name)
      else
        #Comment.tag_counts_on(:tags).limit(MAX_TAGS).order('count desc') # query returning duplicate tags 
        #ToDo: Clean query -> use distinct/pluck through ActiveRecord  
        q = " SELECT DISTINCT tags.name, taggings.tags_count AS count
              FROM tags JOIN (SELECT taggings.tag_id, COUNT(taggings.tag_id) AS tags_count
              FROM taggings INNER JOIN comments ON comments.id = taggings.taggable_id
              WHERE (taggings.taggable_type = 'Comment' AND taggings.context = 'tags')
                AND (taggings.taggable_id IN(SELECT comments.id FROM comments ))
              GROUP BY taggings.tag_id HAVING COUNT(taggings.tag_id) > 0) AS taggings ON taggings.tag_id = tags.id
              ORDER BY count desc LIMIT #{MAX_TAGS}"
        
          ActsAsTaggableOn::Tag.find_by_sql(q)     
      end  

    render :json => hashes.map { |t| {:value => t.name} }
  end
  
end
