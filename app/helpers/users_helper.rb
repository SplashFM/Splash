module UsersHelper
  def avatar_editable?
    @user == current_user
  end

  def tagline_editable?
    @user == current_user
  end

  def link_to_relationship(count, relationship_type = 'following')
    if relationship_type == 'following'
      link_to "#{count} #{t('following', :scope => 'users.show')}", following_relationships_url()      
    end
  end
end
