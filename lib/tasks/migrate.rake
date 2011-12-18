task :migrate => 'avatars:fix_content_type'

namespace :migrate do
  task :refresh_avatars => :environment do
    require 'aws/s3'
    # Load credentials
    config_file = YAML.load_file(File.join(Rails.root, 'config/config.yml')).symbolize_keys
    s3_options = config_file[Rails.env.to_sym]['aws'].symbolize_keys
    bucket = s3_options[:bucket]

    # Establish S3 connection
    s3_options.delete(:bucket)
    AWS::S3::Base.establish_connection!(s3_options)

    User.find_each { |u|
      next unless u.avatar?

      u.avatar.options.hash_secret = ":class/:attachment/:id"
      u.avatar.options.path = "/:class/:attachment/:id/:hash.:extension"

      puts "Writing #{u.id} to file"

      begin
        file = u.avatar.to_file(:original)
      rescue
        begin
          u.avatar.options.path = "/:class/:attachment/:id/:hash.txt"

          file = u.avatar.to_file(:original)
        rescue
          begin
            u.avatar.options.path = "/:class/:attachment/:id/:hash."

            file = u.avatar.to_file(:original)
          rescue
            puts "Hopeless. Moving on."
          end
        end
      end

      File.open("/tmp/avatarz_#{u.id}", 'w') { |f|
        f.binmode
        f.write file.read
      }
    }

    Dir['/tmp/avatarz_*'].each { |p|
      id = File.basename(p).split('_').last

      File.open(p) { |f|
        puts "Saving #{p} to #{id}"

        u = User.find(id)
        u.avatar = f
        u.avatar.options.path = "/:class/:attachment/:id/:style"
        u.save!
      }
    }
  end
end
