class AdminMailer < ActionMailer::Base
  INVITE_EMAIL = 'invite@splash.fm'

  default :from => "\"Splash.FM (#{AppConfig.preferred_host})\" <notifications@splash.fm>"

  def flag(song, user)
    @user, @song = user, song

    mail :to            => AppConfig.email['flag'],
         :subject       => "Song #{song.title} flagged by #{user.nickname}"
  end

  def list_access_requests(requests)
    @requests = requests
    @code     = User.access_code

    mail :to => INVITE_EMAIL, :subject => 'Access requests'
  end
end
