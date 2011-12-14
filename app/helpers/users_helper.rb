module UsersHelper
  def owner?
    @user == current_user
  end

  def avatar_editable?
    owner? && profile_page?
  end

  alias_method :tagline_editable?, :avatar_editable?

  def label_with_current_user(label, opts = {})
    prefix = owner? ? 'my_' : ''

    t(prefix << label, opts)
  end

  def link_to_relationship(user, relationship_type = 'following')
    label = t("#{relationship_type}", :scope => 'users.show')
    url = relationship_type == 'following'? following_path(user) : followers_path(user)
    link = link_to(label, url, :class => 'fancybox')
    count_content = user.send(relationship_type).count.to_s
    count = content_tag(:span, count_content, :class => "avan-demi")

    raw(count + link)
  end

  def link_to_social_site(site, image)
    if current_user.has_social_connection? site
      content_tag(:div,
                    image_tag(image) + "#{site.to_s.capitalize} Account linked",
                    :class => 'buttonStyle2')
    else
      link_label = image_tag(image) + "Link your #{site.to_s.capitalize} Account"
      url = user_omniauth_authorize_path(site)

      link_to link_label, url, :'data-skip-pjax' => true, :class => 'buttonStyle2'
    end
  end

  def user_avatar(user)
    image = image_tag user.avatar_url(:thumb), :id => "user-avatar"

    content_tag(:div, image, :class => 'style')
  end

private
  def profile_page?
    controller_path == 'users'
  end
end
