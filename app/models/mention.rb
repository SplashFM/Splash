class Mention < CommentNotification
  def title
    I18n.t('notifications.mention', :user => notifier.name)
  end
end
