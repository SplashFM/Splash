module CommentsHelper
  def destroy_comment(comment)
    if comment.persisted? && current_user.id == comment.author_id
      link_to "x", [comment.splash, comment], :method => :delete,
                                              :remote => true,
                                              :'data-widget' => 'delete-comment'
    end
  end
end
