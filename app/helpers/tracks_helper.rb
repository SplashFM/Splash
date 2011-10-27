module TracksHelper
  def self.dom_id(track)
    "splash_comment_track_#{track.id}"
  end

  def expand_widget(track)
    link_to(t(".expand"),
            track_path(track),
            :remote        => true,
            :'data-type'   => 'html',
            :'data-widget' => 'track-info-toggle')
  end

  def play_widget(track)
    if track.preview_url?
      link_to(t('tracks.track.play'),
                track.preview_url,
                :'data-widget'     => 'play',
                :'data-track-type' => track.preview_type)
    end
  end

  def show_album?(role)
    role == :splash
  end

  def splash_action_widget(user, target)
    case target
    when Splash
      splashed = Splash.for?(user, target.track)
      label    = t('splashes.splash.resplash')
      id       = SplashesHelper.dom_id(target)
      parent   = target
      track    = target.track
    when Track
      splashed = Splash.for?(user, target)
      label    = t('tracks.widget.splash')
      id       = TracksHelper.dom_id(target)
      parent   = nil
      track    = target
    end

    unless splashed
      l = link_to(label,
                  "##{id}",
                  :'data-widget' => 'splash-toggle')
      f = form_for :splash,
                   :url    => track_splashes_path(track, :parent_id => parent),
                   :remote => true,
                   :html   => {:id => id, :'data-widget' => 'splash-action'} do |f|

        f.hidden_field(:comment, :'data-widget' => 'comment-field') +
          content_tag('div', '', :contenteditable => true,
                                 :'data-widget' => 'comment-box',
                                 :class => 'comment-box') +
          post_to_site_widget('facebook', f) +
          post_to_site_widget('twitter', f) +
          f.submit(label)
      end

      l + f
    end
  end

  def post_to_site_widget(site, form)
    if current_user.has_social_connection? site
      form.label(site.to_sym, I18n.t("splashes.splash.post_to_#{site}")) \
        + check_box_tag("splash[#{site}_post]")
    end
  end

  def track_expandable?(role)
    role == :splash
  end
end
