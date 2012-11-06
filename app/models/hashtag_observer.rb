class HashtagObserver < ActiveRecord::Observer
  observe :comment
  
  def after_create(comment)
    comment.tag_list = comment.hashtags.each{ |tag| tag}
    comment.save!
  end
  
end
