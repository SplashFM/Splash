class Mention < Notification
  def self.notify(target)
    recipients = extract_recipients(target.comment)

    recipients.each { |recipient|
      create!(:target   => target,
              :notifier => target.user,
              :notified => recipient)
    }
  end

  def self.extract_recipients(text)
    mentions = text.try(:scan, /@{(\d+)}/)

    mentions.present? ? User.find(*mentions) : []
  end
end
