require 'mail'
Mail::SMTP.class_eval {
  def deliver!(mail)

    # Set the envelope from to be either the return-path, the sender or the first from address
    envelope_from = mail.return_path || mail.sender || mail.from_addrs.first
    if envelope_from.blank?
      raise ArgumentError.new('A sender (Return-Path, Sender or From) required to send a message')
    end

    # MOJO PATCH in development mode, always send email to hardcoded address
    dev_mailto = ActionMailer::Base.smtp_settings[:dev_mailto]
    if Rails.env == 'development' && dev_mailto.present?
      destinations = [dev_mailto]
    else
      destinations ||= mail.destinations if mail.respond_to?(:destinations) && mail.destinations
    end
    if destinations.blank?
      raise ArgumentError.new('At least one recipient (To, Cc or Bcc) is required to send a message')
    end

    message ||= mail.encoded if mail.respond_to?(:encoded)
    if message.blank?
      raise ArgumentError.new('A encoded content is required to send a message')
    end

    smtp = Net::SMTP.new(settings[:address], settings[:port])
    if settings[:enable_starttls_auto]
      smtp.enable_starttls_auto if smtp.respond_to?(:enable_starttls_auto)
    end

    # MOJO PATCH retry all failed deliveries once.
    begin
      smtp.start(settings[:domain], settings[:user_name], settings[:password], settings[:authentication]) do |smtp|
        smtp.sendmail(message, envelope_from, destinations)
      end
    rescue StandardError => e
      Rails.logger.warn("Encountered error on first attempt to deliver mail: #{$!}. ")
      smtp.start(settings[:domain], settings[:user_name], settings[:password], settings[:authentication]) do |smtp|
        smtp.sendmail(message, envelope_from, destinations)
      end
    end

    self
  end

}
