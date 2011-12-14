namespace :avatar do
  desc "Get and Refreshes Avatar pictures"
  task :refresh => :environment do

    User.find_each do |user|
      user.fetch_avatar if user.provider_avatar_url

      begin
        user.avatar.reprocess! if user.avatar?
        user.save
      rescue AWS::S3::NoSuchKey => e
        puts "Avatar of #{user.name} doesn't exist anymore in S3"
      end
    end
  end
end
