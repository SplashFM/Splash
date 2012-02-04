class Mention < CommentNotification
  def template
    'mention'
  end

  def action
    I18n.t('notifications.mention')
  end
end
