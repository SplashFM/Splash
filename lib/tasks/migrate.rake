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

  task :generate_access_codes => :environment do
    AccessRequest.where(:code => nil).each { |a|
      a.send :generate_code
      a.save!
    }
  end

  task :regenerate_suggested_splashers => :environment do
    User.all { |u|
      u.update_suggestions
      u.save
    }
  end

  task :fix_username_requirements => :environment do
    User.where("nickname similar to '[.-]%' or
                nickname similar to '%[.-]'").each { |u|

      u.update_attribute :nickname, u.nickname.gsub(/(^[.-]|[.-]$)/) { |m| '_' }
    }
  end

  task :fix_track_file_names => :environment do
    UndiscoveredTrack.all.each { |t|
      next unless t.data.file?

      begin
        t.data = t.data.to_file(:original)
        t.send :set_data_content_disposition
        t.save
      rescue => e
        puts e.message
      end
    }
  end
end
