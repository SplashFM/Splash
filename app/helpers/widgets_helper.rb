module WidgetsHelper
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

  def splash_widget(track, user)
    splash = Splash.for(track, user)

    form_for :splash,
             :url    => track_splashes_path(track),
             :remote => true,
             :html   => {'data-widget' => 'splash'} do |f|
      f.submit t('tracks.widget.splash' + (splash ? 'ed' : '')),
               :disabled => splash
    end
  end
end
