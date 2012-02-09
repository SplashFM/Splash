class UserStatsObserver < ActiveRecord::Observer
  observe :splash

  def after_create(splash)
    User.increment_ripple_counts(splash.user_path)

    splash.user.increment_splash_count

    User.update_influences(splash.user_path + [splash.user.id])
    splash.user.record_splashed_track(splash.track.id)
    splash.user.record_splashed_track_week(splash.track.id)

    # If we wanted to be eager about this, we could update the summed_splash_track
    # for all the users following splash.user, but currently we are not so eager.
    # Instead we therefore have the User.recompute_all_splashboards method.
    
  end
end
