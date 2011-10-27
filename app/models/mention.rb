class Mention < Notification
  def self.notify(target)
    recipients = extract_recipients(target.comment)

    recipients.each { |recipient|
      if recipient.following?(target.user)
        create!(:target   => target,
                :notifier => target.user,
                :notified => recipient)
      end
    }
  end

  def self.extract_recipients(text)
    mentions = text.try(:scan, /@{(\d+)}/)

    mentions.present? ? User.find(*mentions) : []
  end

  def title
    I18n.t('notifications.mention', :user => notifier.name)
  end
end
