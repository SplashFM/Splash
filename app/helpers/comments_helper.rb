module CommentsHelper
  def destroy_comment(comment)
    if comment.persisted? && current_user.id == comment.author_id
      link_to "x", [comment.splash, comment], :method => :delete,
                                              :remote => true,
                                              :'data-widget' => 'delete-comment',
                                              :'data-type' => 'html',
                                              :'data-result' => "#comments-#{comment.splash.id}"
    end
  end

  def user_comment_avatar(comment)
    image_tag comment.author.avatar_url(), :size => '46x48' if comment.persisted?
  end

  def number_of_comments(splash)
    if splash.comments.count > Comment::NUMBER_OF_COMMENTS_TO_SHOW
      link_to t(".comment_number", :number => splash.comments.count),
              splash_comments_path(splash),
              :remote => true,
              :'data-widget' => 'more-comments',
              :'data-type' => 'html',
              :'data-result' => "#splash-comments-#{splash.id}"
    end
  end

  def comments_box(splash)
    render :partial => 'comments/comments', :locals => {:splash => splash}
  end
end
