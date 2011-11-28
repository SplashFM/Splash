class AdminMailer < ActionMailer::Base
  default :from => "Splash.FM <notifications@splash.fm>"

  def flag(song, user)
    mail :to            => 'report@splash.fm',
         :subject       => "Song #{song.title} flagged by #{user.nickname}"
  end
end
