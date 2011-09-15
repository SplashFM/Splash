module WidgetsHelper
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
