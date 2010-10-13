EXCEPTION_RECIPIENTS = %w(dev@mojotech.com)
if Rails.env == 'production'
  ExceptionNotifier.sender_address = %("#{APP_NAME} Bug" <bugs@mojotech.com>)
  ExceptionNotifier.exception_recipients = EXCEPTION_RECIPIENTS
else
  require 'ruby-debug'
  Debugger.settings[:autolist] = 1
  Debugger.settings[:autoeval] = 1
  Debugger.settings[:reload_source_on_change] = 1

  debug_file = File.join(Rails.root, 'tmp', 'debug.txt')
  if File.exists? debug_file
    RAILS_DEFAULT_LOGGER.warn "debug.txt detected!  Start remote debugger!"
    Debugger.wait_connection = true
    Debugger.start_remote
    File.delete debug_file
  else
    Debugger.start
  end
end
