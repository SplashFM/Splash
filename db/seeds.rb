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
  user.password = 'mojojojo'
  user.superuser = true
  user.save!
  user.confirm!
end
