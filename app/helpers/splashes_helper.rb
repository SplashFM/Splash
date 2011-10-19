module SplashesHelper
  def self.dom_id(splash)
    "splash_#{splash.id}"
  end

  def expand_splash(splash)
    link_to(t(".expand"),
            splash_path(splash),
            :remote        => true,
            :'data-type'   => 'html',
            :'data-widget' => 'splash-info-toggle')
  end
end
