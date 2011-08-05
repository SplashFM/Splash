# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|

  navigation.items do |primary|

    primary.item :home, 'Home', home_url
    primary.item :tracks, 'Tracks', tracks_url

  end

end

