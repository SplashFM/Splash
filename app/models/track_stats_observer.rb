class TrackStatsObserver < ActiveRecord::Observer
  observe :splash

  def after_create(splash)
    splash.track.increment_splash_count
  end
end
