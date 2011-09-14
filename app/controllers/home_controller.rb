class HomeController < ApplicationController
  before_filter :require_name, :if => 'logged_in?'

  def index
    if logged_in?
      render
    else
      redirect_to new_user_session_path
    end
  end

  private

  def require_name
    if current_user.name.blank?
      redirect_to edit_user_path(current_user), :alert => t('errors.user.attributes.name.blank')
    end
  end
end
