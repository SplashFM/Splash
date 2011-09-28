namespace :db do
  task :refresh => :environment do
    Splash.delete_all
    Track.delete_all

    ENV['FORCE_SEED'] = '1'

    Rake::Task['db:seed_fu'].invoke
  end
end
