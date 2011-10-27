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
    User.find(*text.scan(/@{(\d+)}/))
  end
end
