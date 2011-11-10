require "#{Rails.root}/db/fixtures/splashes.rb"
require "#{Rails.root}/db/fixtures/users.rb"

Comment.seed :body do |s|
  s.splash = Splash.last
  s.body   = "Haha, what a throwback jam!"
  s.author = User.find_by_name('Jack Close')
end
