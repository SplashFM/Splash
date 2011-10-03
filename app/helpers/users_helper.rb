module UsersHelper
  def avatar_editable?
    @user == current_user
  end

  def tagline_editable?
    @user == current_user
  end
end
