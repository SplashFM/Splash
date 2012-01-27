# superuser account
User.seed(:email) do |user|
  user.email = 'dev@mojotech.com'
  if Rails.env.production?
    user.encrypted_password ="$2a$10$k0OiI63t7F3haOiMNC61keVt.g1QgAOElFCw8wcYQePdbwOdREFBu"
  else
    user.encrypted_password = '$2a$10$HgMJqHP9ddNv.BEbWntYleKdVzJijjmnlyUBTkmUIYdj4AzwM9Iha' # password
  end
  user.superuser = true
  user.confirmed_at = Time.now
end

fpath       = File.join(Rails.root, %w(spec support files avatar.jpg))
temp_avatar = Tempfile.new('avatar') and temp_avatar.write IO.read(fpath)


unless Rails.env.production?
  # generic user account
  User.seed(:email) do |user|
    user.email = 'user@mojotech.com'
    user.encrypted_password = '$2a$10$HgMJqHP9ddNv.BEbWntYleKdVzJijjmnlyUBTkmUIYdj4AzwM9Iha' # password
    user.superuser = false
    user.confirmed_at = Time.now
    user.name = 'Mojo User'
    user.nickname = 'MojoJojo'
  end

  if ENV['FACEBOOK_TOKEN'] && ENV['FACEBOOK_UID']
    u = User.find_by_email('user@mojotech.com')

    SocialConnection.seed(:user_id, :provider) { |sc|
      sc.user_id  = u.id
      sc.provider = 'facebook'
      sc.uid      = ENV['FACEBOOK_UID']
      sc.token    = ENV['FACEBOOK_TOKEN']
    }

    friends = FbGraph::User.me(u.social_connections.first.token).friends

    friends.first(15).each_with_index { |f, i|
      User.seed(:email) do |user|
        user.email = "friend#{i}@mojotech.com"
        user.encrypted_password = '$2a$10$HgMJqHP9ddNv.BEbWntYleKdVzJijjmnlyUBTkmUIYdj4AzwM9Iha' # password
        user.superuser = false
        user.confirmed_at = Time.now
        user.name = f.name
        user.avatar = temp_avatar
      end

      fr = User.find_by_email("friend#{i}@mojotech.com")

      SocialConnection.seed(:user_id, :provider) { |sc|
        sc.user_id  = fr.id
        sc.provider = 'facebook'
        sc.uid      = f.identifier
        sc.token    = 'fake'
      }
    }
  end

  User.seed(:email) do |user|
    user.email = 'jack.close@mojotech.com'
    user.encrypted_password = '$2a$10$HgMJqHP9ddNv.BEbWntYleKdVzJijjmnlyUBTkmUIYdj4AzwM9Iha' # password
    user.superuser = false
    user.confirmed_at = Time.now
    user.name = 'Jack Close'
    user.nickname = 'Sparrow'
  end

  User.seed(:email) do |user|
    user.email = 'jack.johnson@mojotech.com'
    user.encrypted_password = '$2a$10$HgMJqHP9ddNv.BEbWntYleKdVzJijjmnlyUBTkmUIYdj4AzwM9Iha' # password
    user.superuser = false
    user.confirmed_at = Time.now
    user.name = 'Jack Johnson'
    user.nickname = 'JJ'
  end

  1.upto(60) { |i|
    User.seed(:email) do |user|
      user.email = "user#{i}@mojotech.com"
      user.encrypted_password = '$2a$10$HgMJqHP9ddNv.BEbWntYleKdVzJijjmnlyUBTkmUIYdj4AzwM9Iha' # password
      user.superuser = false
      user.confirmed_at = Time.now
      user.name = "Mojo User #{i}"
      user.nickname = "mojo_user_#{i}"
    end
  }
end
