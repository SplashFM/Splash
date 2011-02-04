# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|

  navigation.items do |primary|

    primary.item :home, 'Home', home_url

    primary.item :users_admin, 'Users', admin_users_url,
      :class => 'special',
      :if => Proc.new{ signed_in_as_superuser? }

  end

end

