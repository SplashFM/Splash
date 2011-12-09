class Notification < ActiveRecord::Base
  paginates_per 5

  belongs_to :notified, :class_name => 'User'
  belongs_to :notifier, :class_name => 'User'
  belongs_to :target, :polymorphic => true

  scope :unread, where(:read_at => nil)
  scope :by_recency, order('created_at desc')

  after_create :email_notification

  def self.for(user)
    where(:notified_id => user)
  end

  def self.from(user)
    where(:notifier_id => user)
  end

  def as_json(opts = {})
    {:title    => title,
     :type     => self.class.name.parameterize,
     :notifier => notifier.as_json}
  end

  def unread?
    read_at == nil
  end

  def self.mark_as_read(user)
    self.for(user).update_all :read_at => Time.now
  end

  private

  def email_notification
    UserMailer.delay.notification(self)
  end
end
