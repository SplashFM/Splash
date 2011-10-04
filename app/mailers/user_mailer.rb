class UserMailer < ActionMailer::Base
  def following(follower, followed)
    @user = follower
    mail(:to => followed.email,
          :subject => t(:following, :scope => 'emails.subjects', :follower => @user.name))
  end
end
