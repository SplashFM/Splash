module TracksHelper
  def expand_widget(track)
    link_to(t(".expand"),
            track_path(track),
            :remote        => true,
            :'data-type'   => 'html',
            :'data-widget' => 'track-info-toggle')
  end

  def play_widget(track)
    if track.data.file?
      file_name = track.data.path
      extension = File.extname(file_name).split('.').last

      link_to(t('tracks.track.play'),
                track.data.url,
                :'data-widget'     => 'play',
                :'data-track-type' => extension)
    end
  end

  def show_album?(role)
    role == :splash
  end

  def splash_action_widget(user, track)
    splashed = Splash.for?(user, track)
    id       = dom_id(track, :splash_comment)

    unless splashed
      l = link_to(t('tracks.widget.splash'),
                  "##{id}",
                  :'data-widget' => 'splash-toggle')
      f = form_for :splash,
                   :url    => track_splashes_path(track),
                   :remote => true,
                   :html   => {:id => id, :'data-widget' => 'splash-action'} do |f|

        f.text_area(:comment) + f.submit(t('tracks.widget.splash'))
      end

      l + f
    end
  end

  def track_expandable?(role)
    role == :splash
  end
end
