class Notification < ActiveRecord::Base
  module Target
    extend ActiveSupport::Concern

    included do
      has_many :notifications, :as => :target, :dependent => :destroy
    end
  end

  paginates_per 5

  belongs_to :notified, :class_name => 'User'
  belongs_to :notifier, :class_name => 'User'
  belongs_to :target, :polymorphic => true

  scope :unread, where(:read_at => nil)
  scope :by_recency, order('created_at desc')

  after_create :email_notification, :if => :receiver_email_notification_enabled?

  def self.for(user)
    where(:notified_id => user)
  end

  def self.from(user)
    where(:notifier_id => user)
  end

  def action
    I18n.t("notifications.#{self.class.name.underscore}")
  end

  def as_json(opts = {})
    {:title    => "#{notifier.name} #{action}",
     :type     => self.class.name.parameterize,
     :notifier => notifier.as_json,
     :created_at => self.created_at}
  end

  def unread?
    read_at == nil
  end

  def template
    self.class.name.underscore
  end

  def self.mark_as_read(user)
    self.for(user).update_all :read_at => Time.now
  end

  private
  def email_notification
    UserMailer.delay.notification(self)
  end

  def receiver_email_notification_enabled?
    notified.email_preference(self.class.name.underscore)
  end
end
