module Event
  def self.all
    Splash.all
  end

  def self.for(users, since = nil, filters = {})
    q = Splash.for(users, filters).order('splashes.created_at desc')

    since.present? ? q.since(since) : q
  end
end
