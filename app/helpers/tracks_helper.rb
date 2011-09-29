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
    splash = Splash.for?(user, track)

    form_for :splash,
             :url    => track_splashes_path(track),
             :remote => true,
             :html   => {'data-widget' => 'splash-action'} do |f|
      f.submit t('tracks.widget.splash' + (splash ? 'ed' : '')),
               :disabled => splash
    end
  end

  def track_expandable?(role)
    role == :splash
  end
end
