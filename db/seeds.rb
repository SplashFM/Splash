# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)


Notification.all.each do |n|  
  if n.target_type == 'Comment'
     puts n.id 
     if n.target.nil?
      puts "Deleting #{n.id}"
      n.delete 
     end 
  end
end


