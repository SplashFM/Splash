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
      track    = target.track
    when Track
      splashed = Splash.for?(user, target)
      label    = t('tracks.widget.splash')
      id       = TracksHelper.dom_id(target)
      track    = target
    end

    unless splashed
      l = link_to(label,
                  "##{id}",
                  :'data-widget' => 'splash-toggle')
      f = form_for :splash,
                   :url    => track_splashes_path(track),
                   :remote => true,
                   :html   => {:id => id, :'data-widget' => 'splash-action'} do |f|

        f.text_area(:comment) + f.submit(label)
      end

      l + f
    end
  end

  def track_expandable?(role)
    role == :splash
  end
end
