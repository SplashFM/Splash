module SplashesHelper
  def expand_splash(splash)
    link_to(t(".expand"),
            splash_path(splash),
            :remote        => true,
            :'data-type'   => 'html',
            :'data-widget' => 'splash-info-toggle')
  end
end
