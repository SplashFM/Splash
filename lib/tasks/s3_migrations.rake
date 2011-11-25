namespace :s3 do
  desc "Migrate files to S3"
  task :migrate_user_avatars => :environment do
    require 'aws/s3'
    base_dir = File.join(Rails.root, 'public/system/avatars')

    # Load credentials
    config_file = YAML.load_file(File.join(Rails.root, 'config/config.yml')).symbolize_keys
    s3_options = config_file[Rails.env.to_sym]['aws'].symbolize_keys
    bucket = s3_options[:bucket]

    # Establish S3 connection
    s3_options.delete(:bucket)
    AWS::S3::Base.establish_connection!(s3_options)

    # Collect all styles
    styles = ['micro', 'thumb', 'large', 'original']

    # Process each attachment
    User.find_each do |user|
      if user.avatar?
        styles.each do |style|
          path = user.avatar.path(style)

          if !AWS::S3::S3Object.exists?(path, bucket)
            file_path = Dir.glob(File.join(base_dir, user.id.to_s, style, '*'))
            file = open(file_path.try(:first))

            begin
              AWS::S3::S3Object.store(path, file, bucket, :access => :public_read) if file

            rescue AWS::S3::ResponseError => e
              raise
            end
          end
        end
      end
    end
  end
end
