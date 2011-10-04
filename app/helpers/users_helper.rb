module UsersHelper
  def avatar_editable?
    @user == current_user
  end

  def tagline_editable?
    @user == current_user
  end

  def link_to_relationship(count, relationship_type = 'following')
    label = count.to_s
    if relationship_type == 'following'
      label << " #{t('following', :scope => 'users.show')}"
      url = following_relationships_url()
    else
      label << " #{t('followers', :scope => 'users.show')}"
      url = followers_relationships_url()
    end
    link_to label, url
  end

  def follow_label
    if @user == current_user
      link_to t('.edit'), edit_user_path(current_user)
    elsif current_user.following? @user
      render 'unfollow'
    else
      render 'follow'
    end
  end
end
