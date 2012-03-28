module Subscribable
  extend ActiveSupport::Concern

  included do
    handle_asynchronously :subscribe_at_mailchimp
    after_create :subscribe_at_mailchimp
  end

  private

  def subscribe_at_mailchimp
    Hominid::API.new(AppConfig.mailchimp['token']).
      list_subscribe(AppConfig.mailchimp['list_id'], email, {}, 'html', false)
  end

  User.send(:include, self)
end
