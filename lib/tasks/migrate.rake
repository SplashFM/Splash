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
        f = t.data.to_file(:original)

        t.data = f

        t.send :extract_metadata unless t.title.present?
        t.send :set_data_content_disposition,
               t.send(:display_file_name, t.title, t.song_file.extension)
        t.save
      rescue => e
        puts "#{e.message}: #{t.title} (#{t.id})"
      ensure
        f.close! if f
      end
    }
  end

  task :clean_up_missing_avatars => :environment do
    User.find_each(batch_size: 100) { |u|
      begin
        u.avatar.to_file(:original)
      rescue
        u.update_attribute :avatar, nil
      end
    }
  end

  task :set_undiscovered_tracks_rank => :environment do
    ActiveRecord::Base.connection.
      execute "update tracks
               set popularity_rank = -1
               where type = 'UndiscoveredTrack' and popularity_rank is null"
  end

  task :rename_comment_notifications => :environment do
    ActiveRecord::Base.connection.
      execute "update notifications
               set    type = 'CommentForParticipants'
               where  type = 'CommentNotification'"
  end

  task :add_default_comment_email_settings => :environment do
    User.find_each(:batch_size => 100) { |u|
      u.update_attribute(:email_preferences,
                         u.email_preferences.merge(
                           'comment_for_splasher' => 'true',
                           'comment_for_participants' => 'true'))
    }
  end

  task :create_splash_admins => :environment do
    %w(agatof@gmail.com fieds21@gmail.com david@mojotech.com user@mojotech.com).each { |e|
      User.find_by_email(e).try :update_attribute, :superuser, true
    }
  end

  task :create_identicons => :environment do
    UndiscoveredTrack.find_each batch_size: 100 do |t|
      t.send :create_identicon, t.title, t.performers.to_sentence unless t.artwork?
      t.save
    end
  end

  task :clear_duplicate_splashes => :environment do
    Splash.
      select('track_id, user_id, count(*) total').
      group('track_id, user_id').
      having('count(*) > 1').each { |s|

      if s.track_id.nil? || s.user_id.nil?
        puts "AAAAHHHH!"

        next
      end

      first, *rest = Splash.where(track_id: s.track_id, user_id: s.user_id)

      rest.each(&:destroy)
    }
  end

  task :reprocess_artworks => :environment do
    UndiscoveredTrack.find_each batch_size: 100 do |t|
      begin
        t.artwork.options.hash_data = ":class/:attachment/:id/:style/:updated_at"
        f = t.artwork.to_file(:original)
        t.artwork.options.hash_data = ":class/:attachment/:id/:style/:filename"
        t.update_attributes artwork: f unless t.local_data?
      rescue => e
        puts e.message
      end
    end
  end
end
