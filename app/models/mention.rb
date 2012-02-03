class Mention < CommentNotification
  def template
    'mention'
  end

  def title
    I18n.t('notifications.mention', :user => notifier.name)
  end
end
