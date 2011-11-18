module UsersHelper
  def avatar_editable?
    @user == current_user && profile_page?
  end

  def tagline_editable?
    @user == current_user && profile_page?
  end

  def link_to_relationship(user, relationship_type = 'following')
    label = t("#{relationship_type}", :scope => 'users.show')
    url = relationship_type == 'following'? following_path(user) : followers_path(user)
    link = link_to label, url

    count_content = user.send(relationship_type).count.to_s
    count = content_tag(:span, count_content, :class => "avan-demi")

    raw(count + link)
  end

  def link_to_social_site(site)
    link = link_to image_tag("#{site}_64.png"), user_omniauth_authorize_path(site), :'data-skip-pjax' => true
    label = t(".site_connected", :site => site.to_s.titleize) if current_user.has_social_connection? site
    link + label
  end

private
  def profile_page?
    controller_path == 'users'
  end
end
