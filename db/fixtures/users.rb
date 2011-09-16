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

unless Rails.env.production?
  # generic user account
  User.seed(:email) do |user|
    user.email = 'user@mojotech.com'
    user.encrypted_password = '$2a$10$HgMJqHP9ddNv.BEbWntYleKdVzJijjmnlyUBTkmUIYdj4AzwM9Iha' # password
    user.superuser = false
    user.confirmed_at = Time.now
    user.name = 'Mojo User'
  end

  1.upto(30) { |i|
    User.seed(:email) do |user|
      user.email = "user#{i}@mojotech.com"
      user.encrypted_password = '$2a$10$HgMJqHP9ddNv.BEbWntYleKdVzJijjmnlyUBTkmUIYdj4AzwM9Iha' # password
      user.superuser = false
      user.confirmed_at = Time.now
      user.name = "Mojo User #{i}"
    end
  }
end
