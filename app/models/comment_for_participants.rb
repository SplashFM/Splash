class CommentForParticipants < CommentNotification
  def action
    I18n.t('notifications.comment_for_participants',
           :user => target.splash.user.name)
  end
end
