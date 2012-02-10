namespace :redis do
  task :reset => :environment do
    RedisRecord.reset_all
  end

  task :recompute => :environment do
    Track.recompute_splash_counts
    Track.recompute_splash_counts_time_bound

    User.recompute_splash_counts
    User.recompute_ripple_counts
    User.recompute_influence
    User.recompute_splashed_tracks
    User.recompute_top_following
  end
end
