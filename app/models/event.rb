module Event
  def self.all
    Splash.all
  end

  def self.for(user)
    Splash.for(user)
  end
end
