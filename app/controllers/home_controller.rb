class HomeController < ApplicationController
  skip_before_filter :require_user
  before_filter :require_name, :if => 'logged_in?'

  def index
  end

private

  def require_name
    if current_user.name.blank?
      redirect_to edit_user_path(current_user), :alert => t('errors.user.attributes.name.blank')
    end
  end
end
