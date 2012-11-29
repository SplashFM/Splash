class TagsController < ApplicationController
  MAX_TAGS = 15
  SUGGEST_TAGS = 5
  HASH_SIZE = 100
  def index
    # TODO: optimize
    hashes  = 
      if params[:q].present?
        ActsAsTaggableOn::Tag.named_like(params[:q]).limit(SUGGEST_TAGS).sort_by(&:name)
      else
        scope_by(params)
      end  
    #hashes = check_hashSize hashes

    render :json => hashes.map { |t| {:value => t.name} }

  end



 private
  # TODO: Use Jscroll, if tags length is greater 
  def check_hashSize tags
    len = 0
    tags.collect{|t| len=len+ t.name.size}
    if len <= HASH_SIZE 
     return tags
    else
      tags.pop
      check_hashSize tags 
    end 
  end
  
  def scope_by (params)
    #Comment.tag_counts_on(:tags).limit(MAX_TAGS).order('count desc') # query returning duplicate tags 
    #TODO: Clean query -> use distinct/pluck through ActiveRecord  
  
    main_user_id     = params[:user]
    user_ids         = User.following_ids(params[:follower])
    user_ids << main_user_id unless main_user_id.blank?
    if user_ids.present?
      splash_ids = Splash.as_event.for_users(user_ids).map(&:target_id)
      splash_ids = "(" << splash_ids * ',' << ")"
    end
    
    q = " SELECT DISTINCT tags.name, taggings.tags_count AS count
          FROM tags JOIN (SELECT taggings.tag_id, COUNT(taggings.tag_id) AS tags_count
          FROM taggings INNER JOIN comments ON comments.id = taggings.taggable_id
          WHERE (taggings.taggable_type = 'Comment' AND taggings.context = 'tags')
            AND (taggings.taggable_id IN " 
            
    q << (user_ids.blank? ? " (SELECT comments.id FROM comments) ) " : 
                            " (SELECT comments.id FROM comments WHERE comments.splash_id IN #{splash_ids}) ) " ) 
         
    q << " GROUP BY taggings.tag_id HAVING COUNT(taggings.tag_id) > 0) AS taggings ON taggings.tag_id = tags.id
          ORDER BY count desc LIMIT #{MAX_TAGS} "
    
    puts "q: #{q}"
    ActsAsTaggableOn::Tag.find_by_sql(q)     
  end
  
end
