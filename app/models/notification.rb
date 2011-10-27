class Notification < ActiveRecord::Base
  belongs_to :notified, :class_name => 'User'
  belongs_to :notifier, :class_name => 'User'
  belongs_to :target, :polymorphic => true

  scope :unread, where(:read_at => nil)

  after_create :send_following_notification
  def send_following_notification
    UserMailer.following(notifier, notified).deliver
  end

  def self.for(user)
    where(:notified_id => user)
  end

  def unread?
    read_at == nil
  end

  def self.mark_as_read(user)
    self.for(user).update_all :read_at => Time.now
  end
end
