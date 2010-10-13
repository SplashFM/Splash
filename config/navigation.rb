# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|

  navigation.items do |primary|

    primary.item :home, 'Home', home_url

    primary.item :users_admin, 'Users', {:controller => 'admin/users'},
      :class => 'special',
      :if => Proc.new{ signed_in_as_superuser? }

  end

end

