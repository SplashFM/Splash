authorization do
  role :guest do
    # add permissions for guests here, e.g.
    #has_permission_on :conferences, :to => :read
    has_permission_on :admin_users, :to => :deimpersonate
  end

  role :superuser do
    basic_admin = [:users]
    basic_admin.each { |a|
      has_permission_on "admin_#{a}".to_sym, :to => [:active_scaffold]
    }

    has_permission_on :admin_users, :to => :impersonate
    includes :guest
  end
end

privileges do
  # default privilege hierarchies to facilitate RESTful Rails apps
  privilege :manage, :includes => [:create, :read, :update, :delete]
  privilege :read, :includes => [:index, :show]
  privilege :create, :includes => :new
  privilege :update, :includes => :edit
  privilege :delete, :includes => :destroy
  privilege :active_scaffold, :includes => [:export, :show_export, :manage, :update_column, :row, :show_search, :nested, :table, :edit_associated]
end
