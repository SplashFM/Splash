# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.item :home, t('simple_navigation.menus.home'), home_url
    if logged_in?
      primary.item :profile, t('simple_navigation.menus.profile'), profile_url()
    end
  end
end
