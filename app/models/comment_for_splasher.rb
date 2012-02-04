class CommentForSplasher < CommentNotification
  def template
    'comment_notification'
  end

  def action
    I18n.t('notifications.comment_for_splasher')
  end
end
