class Mention < Notification
  scope :as_event, select("notifications.created_at,
                           notifications.id target_id,
                           'Mention' target_type")
  scope :for_users, lambda { |user_ids|
    if user_ids.blank?
      scoped
    else
      where('notifications.notifier_id in (:ids) or
             notifications.notified_id in (:ids)', :ids => user_ids)
    end
  }
  scope :since, lambda { |time|
    time.blank? ? scoped : where(['created_at > ?', Time.parse(time).utc])
  }

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

  def title
    I18n.t('notifications.mention', :user => notifier.name)
  end
end
