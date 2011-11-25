class Mention < Notification
  def self.notify(comment)
    recipients = extract_recipients(comment.body)

    recipients.each { |recipient|
      if recipient.following?(comment.author)
        create!(:target   => comment,
                :notifier => comment.author,
                :notified => recipient)
      end
    }
  end

  def self.extract_recipients(text)
    mentions = text.try(:scan, /@(#{User::NICKNAME_REGEXP})/)

    mentions.present? ? User.nicknamed(*mentions) : []
  end

  def as_json(opts = {})
    if opts[:mention_format] == 'mention'
      {:author  => notifier.as_json,
       :comment => target.as_json,
       :type    => 'mention'}
    else
      super
    end
  end

  def title
    I18n.t('notifications.mention', :user => notifier.name)
  end
end
