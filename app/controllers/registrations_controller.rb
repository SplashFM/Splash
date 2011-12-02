class RegistrationsController < Devise::RegistrationsController
  skip_before_filter :require_user, :only => [:new, :create]

  before_filter :check_http_auth, :only => [:new, :create]
end
