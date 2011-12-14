namespace :avatar do
  desc "Get and Refreshes Avatar pictures"
  task :refresh => :environment do
    User.where(:avatar_content_type => 'text/plain').each { |user|
      user.fetch_avatar
      user.save!
    }
  end
end
