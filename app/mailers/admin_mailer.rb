class AdminMailer < ActionMailer::Base
  default :from => "Splash.FM <notifications@splash.fm>"

  def flag(song, user)
    @user, @song = user, song

    mail :to            => AppConfig.email[:flag],
         :subject       => "Song #{song.title} flagged by #{user.nickname}"
  end
end
