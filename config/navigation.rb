# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.item :home, t('simple_navigation.menus.home'), home_url
    if logged_in?
      primary.item :profile, t('simple_navigation.menus.profile'), profile_url()
      primary.item :top_songs,
                   t('simple_navigation.menus.splashboard'),
                   top_tracks_path do |secondary|
       secondary.item :top_songs,
                      t('simple_navigation.menus.top_songs'),
                      top_tracks_path
       secondary.item :top_users,
                      t('simple_navigation.menus.top_users'),
                      top_users_path
      end
    end
  end
end
