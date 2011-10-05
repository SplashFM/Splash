module Event
  def self.all
    Splash.all
  end

  def self.for(users, filters = {})
    Splash.for(users, filters).order('created_at desc')
  end
end
