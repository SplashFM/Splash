module WidgetsHelper
  def splash_widget(track)
    form_for :splash,
             :url    => track_splashes_path(track),
             :remote => true,
             :html   => {:class  => 'splash'} do |f|
      f.submit t('tracks.widget.splash')
    end
  end
end
