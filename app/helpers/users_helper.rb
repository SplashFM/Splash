module UsersHelper
  def avatar_editable?
    @user == current_user && profile_page?
  end

  def tagline_editable?
    @user == current_user && profile_page?
  end

  def link_to_relationship(count, relationship_type = 'following')
    label = ""
    if relationship_type == 'following'
      label << " #{t('following', :scope => 'users.show')}"
      url = following_relationships_url()
    else
      label << " #{t('followers', :scope => 'users.show')}"
      url = followers_relationships_url()
    end
      the_count = "<span class='avan-demi'>"+count.to_s+"</span>"
      the_link = link_to label, url
      raw(the_count + the_link)
  end

  def link_to_social_site(site)
    link = link_to image_tag("#{site}_64.png"), user_omniauth_authorize_path(site), :'data-skip-pjax' => true
    label = t(".site_connected", :site => site.to_s.titleize) if current_user.has_social_connection? site
    link + label
  end

  def follow_label
    if profile_page?
      content = ''

      if @user.nil?
      elsif @user == current_user
        content = link_to t('.edit'), edit_user_path(current_user)
      elsif current_user.following? @user
        content = render 'users/unfollow'
      else
        content = render 'users/follow'
      end

      content_tag(:div, content, :class => "follow-button")
    end
  end

private
  def profile_page?
    controller_path == 'users'
  end
end
