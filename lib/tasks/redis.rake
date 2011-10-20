namespace :redis do
  task :reset => :environment do
    Track.reset_splash_counts
    User.reset_ripple_counts
  end
end
