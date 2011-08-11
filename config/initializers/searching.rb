Track.max_results = 3
Track.sources     = [
  SoundCloudClient.new(:client_id     => AppConfig.soundcloud['client_id'],
                       :client_secret => AppConfig.soundcloud['client_secret'],
                       :username      => AppConfig.soundcloud['username'],
                       :password      => AppConfig.soundcloud['password'])
]
