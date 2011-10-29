module CommentsHelper
  def destroy_comment(comment)
    if comment.persisted? && current_user.id == comment.author_id
      link_to "x", [comment.splash, comment], :method => :delete,
                                              :remote => true,
                                              :'data-widget' => 'delete-comment'
    end
  end

  def user_comment_avatar(comment)
    image_tag comment.author.avatar_url(), :size => '46x48' if comment.persisted?
  end
end
