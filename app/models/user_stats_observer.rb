class UserStatsObserver < ActiveRecord::Observer
  observe :splash

  def after_create(splash)
    User.increment_ripple_counts(splash.user_path)

    splash.user.increment_splash_count

    User.update_influence(splash.user_path + [splash.user.id])
  end
end
