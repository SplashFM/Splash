namespace :redis do
  task :reset => :environment do
    RedisRecord.reset_all
  end
end
