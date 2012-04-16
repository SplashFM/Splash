class AdminMailer < ActionMailer::Base
  INVITE_EMAIL = 'invite@splash.fm'

  default :from => "\"Splash.FM (#{AppConfig.preferred_host})\" <notifications@splash.fm>"

  def daily_reports(reports)
    @reports = reports

    mail to:      'admin@splash.fm',
         subject: 'Daily stats'
  end

  def flag(song, user)
    @user, @song = user, song

    mail :to            => AppConfig.email['flag'],
         :subject       => "Song #{song.title} flagged by #{user.nickname}"
  end

  def list_access_requests(requests)
    @requests = requests
    @code     = AccessRequest::ADMIN_KEY

    mail :to => INVITE_EMAIL, :subject => 'Access requests'
  end
end
