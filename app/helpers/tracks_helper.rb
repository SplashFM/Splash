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
