class SignupObserver < ActiveRecord::Observer
  observe :user

  def after_create(user)
    welcome_user user
  end

  private

  def welcome_user user
    UserMailer.delay.welcome user
  end
end
