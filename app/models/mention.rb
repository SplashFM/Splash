class Mention < Notification
  def self.notify(target)
    recipient = extract_recipient(target.comment)

    if recipient
      create!(:target   => target,
              :notifier => target.user,
              :notified => recipient)
    end
  end

  def self.extract_recipient(text)
    text.match(/@{(\d+)}/) { |m| User.find(m[1]) }
  end
end
