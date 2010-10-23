User.seed(:email) do |user|
  user.email = 'dev@mojotech.com'
  user.encrypted_password ="$2a$10$k0OiI63t7F3haOiMNC61keVt.g1QgAOElFCw8wcYQePdbwOdREFBu"
  user.password_salt = "$2a$10$k0OiI63t7F3haOiMNC61ke"
  user.superuser = true
  user.confirmed_at = Time.now
end
