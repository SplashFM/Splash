module UsersHelper
  def avatar(user, opts = {})
    img_opts = {:title => user.nickname}
    img_opts.merge!(:width => 45, :height => 45) if opts.delete(:size) == :nano
    img_opts.merge!(:'data-widget' => 'tip') if opts.delete(:'data-widget')

    link_to(image_tag(user.avatar(:micro), img_opts),
            user_link(user),
            opts)
  end

  def avatar_js(*args)
    opts     = args.extract_options!
    prefix   = args.first and prefix << '.'
    img_opts = opts.delete(:size) == :pico ? {:width => 34, :height => 34} : {}
    img_opts.merge!(:'data-widget' => 'tip') if opts.delete(:'data-widget')

    capture_haml {
      haml_tag(:a, {:href => "${#{prefix}url}"}.merge(opts)) {
        haml_tag(:img, :/, {:src   => "${#{prefix}avatar_micro_url}",
                            :title => "${#{prefix}nickname}"}.merge(img_opts))
      }
    }
  end

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

  def user_link(user)
    user_slug_path(user.slug)
  end

  def user_avatar(user)
    image = image_tag user.avatar_url(:thumb), :id => "user-avatar"

    content_tag(:div, image, :class => 'style')
  end

  def email_preference(preference, disabled=false)
    check = check_box "user[email_preferences]",
                      preference.to_sym,
                      {:checked => resource.email_preference(preference),
                        :disabled => disabled},
                      true,
                      false

    content_tag(:li, check + I18n.t("devise.registrations.edit.email_preferences.#{preference}"))
  end

private
  def profile_page?
    controller_path == 'users'
  end
end
