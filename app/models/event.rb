module Event
  def self.all
    Splash.all
  end

  def self.for(user, filters = {})
    Splash.for(user, filters)
  end
end
