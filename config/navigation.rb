# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.selected_class = 'current-page'
  navigation.items do |primary|
    primary.dom_class = 'right avan-demi'
    primary.dom_id    = 'navigation'

    primary.item :home, t('simple_navigation.menus.home'), home_url
    if logged_in?
      primary.item :top_songs,
                   t('simple_navigation.menus.splashboard'),
                   splashboards_path
      primary.item :profile, t('simple_navigation.menus.profile'), profile_url
    end
  end
end
