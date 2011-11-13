class Notification < ActiveRecord::Base
  belongs_to :notified, :class_name => 'User'
  belongs_to :notifier, :class_name => 'User'
  belongs_to :target, :polymorphic => true

  scope :unread, where(:read_at => nil)

  after_create :email_notification

  def self.for(user)
    where(:notified_id => user).order('created_at desc')
  end

  def as_json(opts = {})
    super(:methods => [:title]).
      merge!(:type => self.class.name.parameterize)
  end

  def unread?
    read_at == nil
  end

  def self.mark_as_read(user)
    self.for(user).update_all :read_at => Time.now
  end

  private

  def email_notification
    UserMailer.notification(self).deliver
  end
end
