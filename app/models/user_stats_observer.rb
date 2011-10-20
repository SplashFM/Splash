class UserStatsObserver < ActiveRecord::Observer
  observe :splash

  def after_create(splash)
    User.increment_ripple_counts(splash.user_path)

    splash.user.increment_splash_count
  end
end
