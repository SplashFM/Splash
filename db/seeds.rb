# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
if user = User.find_by_email('dev@mojotech.com')
  puts "Superuser account already exists"
else
  puts "Creating superuser account..."
  user = User.new
  # attributes are not mass-assignable!
  user.email = 'dev@mojotech.com'
  user.password = 'fake-password' # not the actual password, believe it or not
  user.encrypted_password ="$2a$10$k0OiI63t7F3haOiMNC61keVt.g1QgAOElFCw8wcYQePdbwOdREFBu"
  user.password_salt = "$2a$10$k0OiI63t7F3haOiMNC61ke"
  user.superuser = true
  user.skip_confirmation!
  user.save!
end
