task :migrate => 'avatars:fix_content_type'

namespace :migrate do
  namespace :avatars do
    desc "Get and Refreshes Avatar pictures"
    task :fix_content_type => :environment do
      User.where(:avatar_content_type => 'text/plain').each { |user|
        user.fetch_avatar
        user.save
      }
    end
  end
end
