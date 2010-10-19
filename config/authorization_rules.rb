authorization do
  role :guest do
    # add permissions for guests here, e.g.
    #has_permission_on :conferences, :to => :read
  end

  role :superuser do
    has_permission_on :admin_users, :to => [:active_scaffold]
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
  privilege :active_scaffold, :includes => [:manage, :impersonate, :deimpersonate, :update_column, :row]
end
